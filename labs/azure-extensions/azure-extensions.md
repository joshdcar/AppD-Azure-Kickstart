# Azure Monitor Extensions Lab

![metricBrowser][metricBrowser]

## Azure Monitor Overview
[Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/overview) is Azure's cloud native monitoring solution. In additional to traditional application and infrastracture monitoring capabilities it plays a key role in getting visibility into fully managed cloud native platforms where the underlying infrastracture cannot have traditional AppDynamics agents installed. Examples of managed environments on Azure include Azure App Services, Azure Functions, Service Bus, Event Hub, and Azur SQL just to name a couple.

> **TIP:** Although AppDynamics may rely on the Azure Monitor to get visibility into the underlying infrastracture for fully managed services keep in mind that application related visibility is not impaired and many of these services will show up on the flowmap and in snapshots because they contributed to the overall application architecture and are utilized by the underlying application through the platforms APis.

It's also important to understand the role of Application Insights with Azure Monitor. Application Insights is an APM solution that is part of the Azure Monitor family but a seperate feature. You wil find some scenerios such as App Services and Azure Functions where application insights is often turned on by default. It is generally advisable that existing Application Insights is turned off prior to configuring AppDynamics agents.  Although scenerios where they can co-exist it is not recommended.

> **TIP:** It is very common that customers who use Application Insights have also instrumented their applications through the SDK.  Application Insights has historically been very SDK dependant and still requires the SDK for advanced features.  Custom SDK code does not need to be removed and does not conflict with the AppDynamics agents.

## Azure Monitor Extensions for AppDynamics Overview

Azure Monitor Extensions consume Azure Monitor metric which are made available in the form of Custom Metrics in AppDynamics.  Two extensions for Azure Monitor available. The recommended extension, and the one in which this lab uses, is based on the .Net Agent and as such requires a Windows Server, the AppDynamics .Net Agent, the [AppDynamics Manager for .Net Agent Extensions](https://www.appdynamics.com/community/exchange/extension/appdynamics-net-agent-extension-manager/), and finally the actual [Azure Monitor .Net Extension](https://www.appdynamics.com/community/exchange/extension/azure-monitor-net-extension).  

The Azure Monitor .Net Extensions make use of the [Azure Monitor REST API](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/rest-api-walkthrough) to poll and consume metrics. Although knowledge of the API is not required to configure the extensions it can be helpful when understanding the varios resource configuration options and limitations.

### **Access and Credentials**

As part of your workshop welcome message you will have received some credentials in a format similiar to the following:

```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxx",
  "displayName": "appd-sp-my-name",
  "name": "http://appd-sp-my-name",
  "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxx"
}
```
These are access details for a Azure Service Principal, a type of Azure AD Application, that acts as credentials when configuring the Azure Monitor Extensions to communicate with Azure resources to query metrics. 

There are several methods to generate service accounts. One common approach outside the portal is the Azure CLI command **az ad sp create-for-rbac** [command](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create-for-rbac). By default these commands create subscription level contribute permissions which is *VERY* permissive. It is suggested to use a reader role.  In the case of this workshop the credentials are reader and the scope is limited to the resource group of the attendee.

> **TIP:** You can actually use these credentials to [login](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest) with the Azure CLI as well. You are still limited by the role and scope but can come in very handy at times!


## **Lab Scenerio**

In this lab we will build on the previous [Azure App Services Lab](../app-services/azure-app-service-monitoring.md) by configuring the Azure Monitor Extensions to pull metrics for the Second Chance Parts Web & API Applications and the App Service Plans to provide an additional level.

> **NOTE** Common metrics such as CPU and Memory will not show up within the Node level details because they are not part of traditional infrastracture that is reported on through machine and service visibility agents. They are instead available through custom metrics in the metric browser. 

### **Primary Objectives**

* Provision Azure Resource with Powershell
* Install the AppDynamics Manager for .Net Agent Extensions
* Install the Azure Monitor .Net Extension
* Configure the Azure Monitor .Net Extension for Azure App Service and App Service Plan Resources
* Discover Azure Monitor Metrics in the Metrics Browser

### **Azure Resources**

[todo list sites and app service plan resources]

> **Tip:** Visit [Supported metrics with Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported) for a complete listing of all the metrics that area available to be consumed by the extensions. 

#### **Resource Providers**

[todo]


## **Lap Steps**

### **Step #1** - Provision Azure VM with Powershell

Powershell is an extremly popular cross platform scripting language developed by Microsoft and very popular with Server administrators. It's also often the tool of choice for Azure administrator already comfortable with the powershell. Although often more verbose then the Azure CLI it can also be more powerfull and also offer an alternative to defining Azure resources through ARM templates and JSON.

In this step we will be provisioning azure resources through powershell. In the previous excercise you saw how we could use the Azure CLI (iniated from a powershell script) to deploy resources defined within an ARM Template and JSON. In this excercise we will use Powershell itself to provision Azure resources, specifically a Virtual Machine for the Azure Monitor extensions. 

### **Azure Resources Being Deployed**

The following Azure Resources will be deployed as part of this step:

* Azure Virtual Machine (Windows Server 2016)

### **Deployment Script**

The Azure Monitor Extensions Lab contains a single unified powershell script found within your project under **/labs/azure-extensions/deploy/azure-deploy.ps1** that performs the following actions:

1. Provision and Azure Virtual Machine

2. Retrieves the Public IP Address assigned to the virtual machine

#### **Understanding the Deployment Script**

Similiar to other deployment scripts we will pull in some common workshop lab coniguration details including the Resource Group and default Virtual Machine credentials. Notice the way in which powershell handles credentials with the **PSCredential** object and the password with the **ConvertTo-SecureString** funtionality.

``` powershell
$configPath = join-path "../../../environment" -ChildPath "config.json"
$config = Get-Content $configPath | ConvertFrom-Json

Write-Host ("Current Configuration:") -ForegroundColor Green
Write-Host (-join("Resource Group: ", $config.AzureResourceGroup)) -ForegroundColor Green

$VMName = "appd-dotnet"
$PublicIPAddressName = "appd-dotnet-ipaddress"

$VMLocalAdminUser = $config.DotnetAgentVMUsername
$VMLocalAdminSecurePassword = ConvertTo-SecureString $config.DotnetAgentVMPassword -AsPlainText -Force
$VMSize = "Standard_B2ms"

$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
```
> **TIP:** If you wanted the script to prompt for credentials you could use the [Get-Credential](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential?view=powershell-7) command within Powershell. 

The core of this powershell script is the setting of the virtual machine properties and the execution of the [New-AzVM](https://docs.microsoft.com/en-us/powershell/module/az.compute/new-azvm?view=azps-3.7.0) command. You'll see lots of different examples of usage for this command but that speaks to the power of using Powershell for provisioning as it can be highly customized to meet specific use-cases. *Take Special note of the $PublicIpAddressName* variable.

> **NOTE:** In th case of this script we are using a custom Windows Server 2016 image that we created for this workshop that is available in our Shared Image Gallery of VM images. It is very common for organizations to use Shared Image Galleries and Shared images for VM creation. In our case we installed Chrome and disabled some default security to make our agent installation process a little quick. We could hav easily used a basic Windows Server 2016 image from Microsoft. 

Finally notice the ouptut of the IP Address. Take note of that address as we will be using it to RDP into our server for additional deployment steps. 

``` powershell

$vmParams = @{
    ResourceGroupName = $config.AzureResourceGroup
    Name = $VMName
    Location = $config.Region
    ImageName = '/subscriptions/d4d4c111-4d43-41b2-bb7f-a9727e5d0ffa/resourceGroups/workshop-resources/providers/Microsoft.Compute/galleries/Azure_Workshop_Images/images/Appd_Workshop_DotAgent_VM/versions/1.0.0'
    PublicIpAddressName = $PublicIPAddressName
    Credential = $Credential
    OpenPorts = 3389
    Size = $VMSize
  }

$newVM1 = New-AzVM @vmParams

$publicIp = Get-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $config.AzureResourceGroup 

Write-Host (-join("Public IP (RDP Address): ",$publicIp.IpAddress)) -ForegroundColor Green
```

> **TIP:** Azure's powershell features have evolved over time and as cross platform support was added to Powershell. You may notice references to older versions of the Azure commands that include **RM** (standing for Resource Manager) naming scheme which is being retired along side some of the older powershell modules for Auzre. Ensure you're looking at the latest documentation. 

#### **Executing the Deployment Script**

From a terminal window navigate to your workshop project folder and the **/labs/azure-extensions/deploy** folder and execute the following command.

> **Windows**  

```> pwsh .\azure-deploy.ps1```

> **Mac**  

```> pwsh ./azure-deploy.ps1```

#### **Expected Output**

![extensionsDeployOutput][extensionsDeployOutput]

> **TIP:** If you get an errors during the execution ensure that you have correctly installed all the workshop prerequisites.  It is not uncommon to see deployment errors during the deployment. If this is the case review the output of the script for deployment commands that can be executed again.

#### **Confirm RDP Access**

Confirm you have RDP Access to the server with your RDP application of choice. As part of the provisioning port 3389 has been opened.

![rdp][rdp]

### **Step #2** - Install Dotnet Agent

Visit the AppDynamics controller address provided as part of the workshop welcome email. From the controller download the latest AppDynamics .Net Agent and install the agent on the server. .Net Agent install instructions can be found on the [AppDynamics documentation site](https://docs.appdynamics.com/display/PRO45/Install+the+.NET+Agent+for+Windows). It is not neccesary to have any applications running in IIS. Remember to confirm your configuration is successful in the agent's **config.xml** typically found at **C:\ProgramData\AppDynamics\DotNetAgent\Config**.

![agentDownload][agentDownload]

> **IMPORTANT!!!** For all downloaded files (executable and dlls) ensure they are **not blocked**. Files downloaded from an unknown internet source are often blocked by Windows and will cause various issues during the install (see troubleshooting section). Right click on each executable and dll and choose check unblock. 
> ![unblock][unblock] 

### **Step #3** - Install Dotnet Agent Extensions

The Azure Monitor .Net Extensions are based on the .Net Agent Extensions.  The Agent Extensions can be [downloaded](https://www.appdynamics.com/community/exchange/extension/appdynamics-net-agent-extension-manager) from the exchange. 

![dotnetManager][dotnetManager]

Following downloading the zip file should be extracted to **C:\ProgramData\AppDynamics** . This is not required but is helpful for uniformity as it's next to the .net agent configuration as well.

![dotnetManagerExtract][dotnetManagerExtract]

**Execute AppDynamics.Extension.Manager** from the **C:\ProgramData\AppDynamics\AppDynamics.ExtensionManager** folder and select "Install" of the Service. Once installed confirm the service is running both in the Manager UI and the services console.

![managerService][managerService]

### **Step #4** - Install Azure Monitor Extensions

The Azure Monitor .net Extension can be found on the [AppDynamics exchange](https://www.appdynamics.com/community/exchange/extension/azure-monitor-net-extension).  

* Create a new folder called **SecondChanceParts-WebApps** located in the Extensions Manager extensions folder located at **C:\ProgramData\AppDynamics\AppDynamics ExtensionManager\Extensions**

* Copy zip file contents into the newly created **C:\ProgramData\AppDynamics\AppDynamics ExtensionManager\Extensions\SecondChanceParts-WebApps** folder.

* Update configuration for extension.xml

![extensionsFolder][extensionsFolder]

#### **Updating extension.xml Configuration**

The extension.xml contains the important configuration required for Azure monitor including which resources metrics are used and the credentials utilized to access those resources. 

The example provided in this lab only covers web application resource metrics. The data property in the Instance node of the configuration will generally use the following pattern for identifying resources.

data="*resourceGroups/**[resource group name]**/providers/**[resource/path]**/providers/**[ResourceProvider]***"

![extensionsConfig][extensionsConfig]

1. The name of this extension instance as it will appear in the extension manager. This should be meaningful especially if multiple monitoring instanced are used (see below tip)

2. This is the instance name as it will appear in the metrics explorer. In this case we are monitoring web applications and we have multiple web applications we want to monitor (see example metric explorer at the top of this lab)

3. This should be replaced with the name of your resource group.

4. This should be replaced with the names of your api and web applications. 

5. This is specifically using Microsoft.Web/sites for resources. Other resources will have different resource URIs. 


> **TIP:** It is often necesary when organizing larger amounts of Azure resources to use multiple instances\copies of the extension into each folder.  This allows for some more granular management and control and is required when using multiple different service principals to authenticate to different resources across multiple applications or subscriptions. Building on the above example we could have we could have SecondChanceParts-WebApps, SecondChanceparts-AppServicePlans, SecondChanceParts-CosmosDB. Each would be picked up a seperate extension in the extension manager. 

Lastly the credentials portion of the configuration should be updated to relfect the credentials provided in your workshop welcome message.  Notice that some of the nomenclature is slightly different between the configuration and those provided by Azure Service Principals. Although the authentication method is OAUTH Azure has a slightly different naming scheme for common OAUTH properties:

* CLIENT_ID = appId
* TENANT_ID = tenant
* CLIENT_KEY = password
* SUBSCRIPTION_ID = subscription
* ALLOWED_METRIC_NAME_REGEX = "" (remove the default *)




#### **Confirming Configuration**

Finally lets go ahead and save our extension file and perform the following steps:

1. Save the extension.xml
2. Exit the Extension Manager and restart the **AppDynamics.Agent.Extension** through the Windows Service Console.
3. Open the Extension Manager and confirm your extension is registered. (*see reference screenshot 3*)
4. Review the **ExtFrameworkLog** located in the **C:\ProgramData\AppDynamics\AppDynamics ExtensionManager\Logs** folder that the Metric entries (Adding Perf Count messages) are present and the config.xml has been updated. (*see reference screenshot #4*)
5. Restart the AppDynamics.Agent.Coordinator. This is required for the new config.xml settings written by the extension manager are picked up.
6. Confirm through the Agent Log located at **C:\ProgramData\AppDynamics\DotNetAgent\Logs** that the new metrics are registered (*see reference screenshot #6*). You can also review the metrics payload in the agentlog to see that extension metrics are being sent. 

> **NOTE:** Metrics in the .net agent from the Azure extension appear as custom perf-counter metrics

*Ref #3 Registered Extension*
![extensionsConfirm][extensionsConfirm]

*Ref #4 ExtFrameworkLog.log*
![extensionsLogConfirm][extensionsLogConfirm]

*Ref #6 Agent Log*
![extensionsAgentLog][extensionsAgentLogs]


#### **Troubleshooting Azure Monitor Extensions**

**OS Blocked File**
Review Extension Logs. You may find something similiar to below:

![extensionsBlockError][extensionsBlockError]


[metricBrowser]: ../../images/labs/extensions_metric_browser.png "metricBrowser"
[rdp]: ../../images/labs/extensions_rdp.png "rdp"
[agentDownload]: ../../images/labs/extensions_agent_download.png "agentDownload"
[dotnetManager]: ../../images/labs/extensions_dotnet_manager.png "dotnetManager"
[dotnetManagerExtract]: ../../images/labs/extensions_dotnet_manager_extract.png "dotnetManagerExtract"
[unblock]: ../../images/labs/extensions_unblock.png "unblock"
[managerService]: ../../images/labs/extensions_manager_service.png "managerService"
[extensionsFolder]: ../../images/labs/extensions_folder.png "extensionsFolder"
[extensionsConfig]: ../../images/labs/extensions_extension_config.png "extensionsConfig"
[extensionsConfirm]: ../../images/labs/extensions_extension_confirm.png "extensionsConfirm"
[extensionsLogConfirm]: ../../images/labs/extensions_log_confirm.png "extensionsLogConfirm"
[extensionsAgentLogs]: ../../images/labs/extensions_agent_log.png "extensionsAgentLogs"
[extensionsBlockError]: ../../images/labs/extensions_block_error.png "extensionsBlockError"
[extensionsDeployOutput]: ../../images/labs/extensions_deploy_output.png "extensionsDeployOutput"