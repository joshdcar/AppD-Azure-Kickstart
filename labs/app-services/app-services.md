# Azure App Services Lab

![scpFlowmap][scpFlowmap]

## Lab Scenario

Second Chance Parts (SCP) is an online ecommerce company that that sells auto parts sources from auto junk yards. SCP has historically hosted it's application on premise in traditional virtual machines. Management of these virtual machines, the related SQL Server, has been a burden and has led to both security and capacity incidents in the past.  SCP wants to move it's workloads to Azure but also take advantage of platforms on Azure that would reduce this burden and risk but not require them to make significant changes to their existing application architecture which is based on ASP.NET and SQL Server.

To address these needs SCP has chosen Azure's App Services and Azure SQL with it's fully managed, secure, and scalable infrastructure as it's migration platform of choice.  Additionally they have chosen to use Service Bus, Azure's Native Enterprise Messaging platform, to provide for future integration opportunities.

### Lab Primary Objectives

* Provision Azure App Services to support the Web UI and APIs with ARM Templates
* Provision and Azure SQL Database with ARM Templates
* Deploy the application components to Azure App Services
* Deploy, Configure, and Validation\Troubleshoot the AppDynamics Agent

### Tech Stack

Second Chance Parts is historically a microsoft shop so they have chosen the following application architecture:

* .Net Core 3.1
* ASP.NET Razor Pages
* ASP.NET Web API (Rest)
* Azure SQL

## App Service Overview

[Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/)s is one of the most popular PaaS (Platform as a Service) offerings on Azure and enables you to build and host web apps and APIs in the programming language of your choice and is all done without having to manage the underlying infrastructure.  

Azure App Services are made up of two key components:

* **App Service**  - Contains the web site (or API) and all of its configuration and code

* **App Service Plan**  - The underlying infrastructure that equates to the physical VMs behind the scenes. Multiple sites are permitted to be associated with a single App Service Plan allowing for higher density deployments. Similar to a single server hosting IIS with several separate IIS sites. There are several tiers of app service plans available that have different abilities and scaling characteristics.

AppDynamics has first class integration with Azure App Services through a feature referred to as **Site Extensions**. Site extensions allow for the deployment of configuration and files to an application deployed to Azure App Services.  In the case of AppDynamics we have the preferred option of deploying our agent through these site extensions making the agent deployment experience for Azure App Services quite simple and fairly turn key.

Azure App Services supports various languages and platforms from windows and linux to .net, php, java, and node.js.  The site extensions today only supports the deployment of the .net agent to windows. AppDynamics supports the other environments but agents must be deployed with other patterns such as CI\CD.

> **TIP:**  Azure App Services has gone through re-branding over the years. Azure App Services, Azure Web Sites, Azure Mobile Apps, Azure API Apps are all Azure App Services. However, a legacy PaaS platform on Azure referred to as Cloud Services is still available for customers.  This is a separate offering that AppDynamics does support but is not covered in this lab.

## Kudu

Because Azure App Services is in a managed environment there is no access to the underlying operating system and runs within a [Sandbox](https://github.com/projectkudu/kudu/wiki/Azure-Web-App-sandbox) which comes with some restrictions on some of the processes that can be run and executed. This includes no ability to "Remote Desktop" into the servers and perform common tasks like viewing processes, logs, uploading files, etc.

![kuduHome][kuduHome]

To compensate for this each Azure App Service has a Kudu site deployed along side it. Kudu is a web based management interface where you can perform various administrative tasks (beyond the portal administration) and also provides some of the underlying functionality provided by Azure App Services such as git based deployments. Most importantly Kudu is the engine that manages and deploys **site extensions**.  

Kudu sites have a naming convention of *https://[my-site-name].scm.azurewebsites.net*. Even when a site has a custom domain it still retains the original default "azurewebsites.net" domain and scm prefix. Kudo is generally launched from the administrative pages of Azure App Services on the portal.

**Kudu plays a very important role with AppDynamics** and provides us the interface to troubleshoot agent deployments and access to agent logs.

[TODO - KUDU Image]

## Lab Steps

## **Step #1** - Azure Resource & Application Deployment

### **Azure Resources Being Deployed**

The following Azure Resources will be deployed as part of this step:
  
    * Azure App Service (Web UI)
    * Azure App Service Plan (Web UI)
    * Azure App Service (API)
    * Azure App Service Plan (API)
    * Azure SQL Database

![resourceDiagram][resourceDiagram]

> *TIP:* This diagram was automatically created using the ARM Template Previewer Extension in Visual Studio Code and will automatically preview any valid ARM Template. In this case the *azure-deploy.json* located in the /labs/app-services/deploy folder of the workshop repo.

### **Deployment Script**

The Azure App Services Lab contains a single unified powershell script found within your project under **/labs/app-services/deploy/azure-deploy.ps1** that performs the following actions:

1. Compile and packaging of the the SecondChanceParts component into a "zip" file

2. Provisioning of Azure resources from an ARM template and executed by the Azure CLI

3. Deployment of the packaged components to the Azure App Services via the Azure CLI.


### Executing the Deployment Script

From a terminal window navigate to your workshop project folder and the **/labs/app-services/deploy** folder and execute the following command.

 **Windows**

```Powershell

   pwsh .\azure-deploy.ps1

```

 **Mac**

```Powershell

   pwsh ./azure-deploy.ps1

```

> **DEEP DIVE** Interested in understanding more about how this script works? Jump to **[DEEP DIVE - Better Understanding the deployment script](#understandingdeploy)** for more details!

### **Expected Output**

The execution of this command should reflect something similar to the following image.

![deploymentOutput][deploymentOutput]

> **TIP:** If you get an errors during the execution ensure that you have correctly installed all the workshop prerequisites.  It is not uncommon to see deployment errors during the deployment. If this is the case review the output of the script for deployment commands that can be executed again.

### **Validate Azure Resource Deployment**

Validate that your azure resources are deployed by logging into the Azure Portal and opening your resource group.

![appServiceResources][appServiceResources]

### **Check your Website**

Verify that the web site is up and running by visiting it in your browser. You can find your websites URL in the portal by opening the **appd-scp-web** labeled app service resource.

![appServiceUrl][appServiceUrl]

#### Verify the site is running. Start shopping by entering a name and selecting "Start Shopping"

![scpSite][scpSite]

## **Step #2** - Installing the AppDynamics Agent

In this step we will be installing and configuring the AppDynamics Agents through Site Extensions. **You will need the the name and access key from your controller**.

> **TIP** Site Extensions can be deployed and configured automatically through ARM Templates. Review the ARM Template **azure-deploy-extensions.json** located within this labs deployment folder. Take special note of the site extension elements along with the AppDynamics appsettings elements.  This is a true zero touch deployment mechanism that organizations using CI\CD may find attractive.

### 1. Navigate to the Web Azure App service and select **Extensions** from the left menu (scrolling down). Then select **Add**

![extension1][extension1]

### 2. Scroll to the AppDynamics 4.5 extension. Also ensure you accept the legal terms and select **OK**

![extension2][extension2]

### 3. Confirm the extension has been installed and select **Browse** from the dialog

![extension3][extension4]

### 4. You should be taken to the AppDynamics Configuration Page. Enter the appropriate details and choose **Validate**

![extension4][extension5]

> **ALERT** On occasion you may get an error relating to path not found (or similar) when accessing this site after activating the site extensions. Return to the azure portal and restart the web application and try visiting the same page again.

### 5. As directed - restart the web application

![extension6][extension6]

### 6. **REPEAT same steps 1-5 for the API App Service**

### 7. Generate traffic on the Second Chance Parts site and ensure you have the flowmap and BTs populating

![scpFlowmap][scpFlowmap]

## **Step #3** - Reviewing Logs and Troubleshooting

All files can be access from within the Kudu console by going to **Debug console -> cmd** on the main top menu.

### **AppDynamics Logs**

Logs are available from the Kudu console but not located in the typical .net agent location and instead within the app service's centralized log file location located at **D:\home\logfiles\AppDynamics**.

![kuduLog][kuduLog]

> **Tip** The storage used by Azure App Services is shared across all instances. As additional instances are added to an App Service Plan those logs are all written to the same files. In the profiler folder you will see each file separated by process id. Those may be process ids that are coming from different instances.

### **Additional Agent Settings**

Additional agent settings, for example the AppDynamicsConfig.json can be found at **d:\home\SiteExtensions\AppDynamics.WindowsAzure.SiteExtensions.4.5.Release\AppDynamics**

![kuduAgentFiles][kuduAgentFiles]

## Generating Load

You can generate the load by visiting the Second Chance parts Site. Ensure you perform some of the following actions to ensure your flowmap is generated and business transactions are identified:

* Create a new shopping cart with your name and select "Start Shopping"
* Click on Parts/Carts/CartItems/Privacy links in the navigation

![siteHome][siteHome]

* Add Items to your cart and checkout **This page exclusively will generate downstream API requests**
* Unlike a real shopping cart you can checkout any time you want (but you can never leave!). Selecting Checkout several times will generated topic messages behind the scenes.

![siteCheckout][siteCheckout]

### **Confirming Agent is Loaded**

It can be helpful to confirm that the agent is loaded into the application to determine if additional resets are required or if there are other issues preventing the agent from attaching. You can review processes and look for the AppDynamics module is loaded within the process by viewing the **Process Explorer** from the top menu.

![kuduProcesses][kuduProcesses]
![kuduProcessModules][kuduProcessModules]

## Better Understanding the Deployment

<a name="understandingdeploy"></a>

Defining and provisioning Azure resources outside the portal is considered a best practice. Azure provides several paths including ARM Templates, Azure CLI, and Azure Powershell. Arguably ARM Templates is the most popular and is the core of the provisioning solution utilized by this lab.

The Deployment Script can be broken into 3 main functional sections:

1. Building and Packaging the .Net application
2. Deploying Azure Resources through ARM Templates
3. Deploying the application packages to Azure App Services.

## **Building and Packaging the .Net application**

This is not a developer focused workshop so you don't have to worry too much about the details but you should understand the basics of how .net applications are compiled. This is especially helpful when working with any CI\CD platform as well.

For the sake of brevity we will look at how the ASP.NET Razor Page application is compiled and packaged. THe same holds true for the ASP.NET Web API App.

**dotnet publish** requires a path to a .csproj (the project file for a c# .net app) file. Publish both compiles and packages the deployment in the same step. 

Specific to Azure App Services (and Azure Functions) we are using the [**Zip Deploy**](https://docs.microsoft.com/en-us/azure/app-service/deploy-zip) functionality which greatly simplifies deployment and is a preferred method for application deployment to Azure. We are using Powershell functionaliy to provide the compressed folder. Note that we are storing the **$webPackage** variable for later use. When running the script you will see the output in your Visual Studio Code Editor.

```powershell

  # Compile & Publish the Web Site
  $webcsproj = join-path "../src/SecondChanceparts.Web" -ChildPath "SecondChanceParts.Web.csproj"
  dotnet publish -c Release $webcsproj
  $webPublishFolder =  join-path "../src/SecondChanceparts.Web/bin/release/netcoreapp3.1" -ChildPath "/publish"

  # Create the Web Site Deployment Package
  $webPackage = "secondchanceparts.web.zip"
  if(Test-path $webPackage) {Remove-item $webPackage}
  Add-Type -assembly "system.io.compression.filesystem"
  [io.compression.zipfile]::CreateFromDirectory($webPublishFolder, $webPackage)

```

![zipDeploy][zipDeploy]

> **NOTE:** You can ignore the "join-path" commands if your scripts do not have to target multiple platforms. For this workshop we had to ensure the scripts would execute on both windows and macs which have different path separators.

## **Deploying ARM Templates**

ARM stands for Azure Resource Manager and is the underlying fabric of Azure today. [ARM Templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview), a type of Infrastructure as Code, are a way to declare resources you want, the types, and properties within a JSON file. ARM Templates are referred to as Infrastracture as Code.  The core elements defined within an ARM template include Parameters, Variables, and Resources.

ARM templates in of themselves are just definitions. ARM templates can be executed in the Azure portal, through the Azure CLI, or through Azure Powershell commands. For this lab we used the Azure CLI.

The core of the command below is [**az group deployment create**](https://docs.microsoft.com/en-us/cli/azure/group/deployment?view=azure-cli-latest). The important parameters here are the **--resource-group** which is where we are deploying the resources to and the **--template-file** which is our ARM template. Additionally we have **parameter** values that we are passing in from a file in our case that is used in the ARM template.

*Every Azure CLI command can have an output type defined by the **-o** and a optional **query** switch which allows you to query and return only specific elements. This becomes very useful for scripting and in this case allows us to pull out the web and api app names from the results to be used later in the script.*

```powershell
[array]$appNames = (az group deployment create `
            --name "appd-azure-deployment" `
             --resource-group $resourceGroup `
             --template-file $provisionFile `
             --parameters @azure-deploy-params.json `
             --query '[properties.parameters.webAppName.value,properties.parameters.apiAppName.value]' -o tsv)

$webAppName = $appNames[0]
$apiAppName = $appNames[1]
```

### **Breaking down the ARM Template**

As part of this lab we specifically work with the three core resource types being deployed as part of this lab:

* Microsoft.Sql/servers
* Microsoft.Web/serverfarms (App Service Plans)
* Microsoft.Web/sites (App Services)

### Microsoft.Sql/servers

Here we are defining the SQL Server and as properties the login parameters which are passed in when running the ARM Template (shown later).

```json

  {
        "name": "[variables('sqlServerName')]",
        "type": "Microsoft.Sql/servers",
        "apiVersion": "2019-06-01-preview",
        "location": "[parameters('location')]",
        "tags": {
          "displayName": "SqlServer"
        },
        "properties": {
          "administratorLogin": "[parameters('sqlAdministratorLogin')]",
          "administratorLoginPassword": "[parameters('sqlAdministratorLoginPassword')]",
          "version": "12.0"
        },
        "resources": [...]
  }

```

A child resource of a SQL Server is the all important database which in the case of Azure SQL is where much of the core functionality for deploying Azure SQL is defined.

The important elements to recognize here are of course the type "databases" and also the property "edition" which essentially defines the tier of Azure SQL you are provisioning.

> **TIP** Take note of the [**dependsOn**](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/define-resource-dependency) property. These are very important to ensure the correct order of operations. In this case we would not want to provision the database unless the SQL Server itself was provisioned. This concept is used widely throughout ARM Templates.

```json
{
          "name": "[variables('databaseName')]",
          "type": "databases",
          "apiVersion": "2015-01-01",
          "location": "[parameters('location')]",
          "tags": {
            "displayName": "Database"
          },
          "properties": {
            "edition": "[variables('databaseEdition')]",
            "collation": "[variables('databaseCollation')]",
            "requestedServiceObjectiveName": "[variables('databaseServiceObjectiveName')]"
          },
          "dependsOn": [
            "[variables('sqlServerName')]"
          ],
          "resources": [
            {
              "comments": "Transparent Data Encryption",
              "name": "current",
              "type": "transparentDataEncryption",
              "apiVersion": "2014-04-01-preview",
              "properties": {
                "status": "Enabled"
              },
              "dependsOn": [
                "[variables('databaseName')]"
              ]
            }
          ]
        }
```

### Microsoft.Web/serverfarms

Serverfarms define the Azure App Service Plan that equates to the actual compute tier the web site may run under. Remember that you can have multiple sites deployed to a single app service plan if you choose to although you may run into resource contention just like any shared environment.

The important element in cases of the serverfarms is the sku which in this case equates to the first tier of a basic plan. Visit [app service plans](https://azure.microsoft.com/en-us/pricing/details/app-service/plans/) documentation to further understand different options available.

```json
{
      "type": "Microsoft.Web/serverfarms",
      "apiVersion": "2018-02-01",
      "name": "[variables('webHostPlan')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "B1",
        "capacity": 1
      },
      "properties": {
        "name": "[variables('webHostPlan')]"
      }
    },
```

### Microsoft.Sql/sites

Sites define the actual web application itself and are key in having an opportunity to place configuration within the site. In the case of the Connection String its dynamic configuration with some new SQL connection information available from the newly created resources.  **dependsOn** is very important in this case because sites depends on everything else so it should be provivsioned last.

> **TIP:** Notice the appSettings section. The AppDynamics agents allows for additional settings to be defined within the application configuration. All appsettings on azure app services become **environmental variables** so this is an opportunity to make custom configuration changes for the agent at deployment time.

```json

{
      "apiVersion": "2015-08-01",
      "type": "Microsoft.Web/sites",
      "name": "[variables('webApp')]",
      "location": "[parameters('location')]",
      "kind": "app",
      "dependsOn": [
        "[resourceId('Microsoft.Web/serverfarms', variables('webHostPlan'))]",
        "[resourceId('Microsoft.Sql/servers', variables('sqlserverName'))]"
      ],
      "properties": {
        "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', variables('webHostPlan'))]",
        "siteConfig": {
          "connectionStrings": [
            {
              "name": "SecondChancePartsContext",
              "connectionString": "[concat('Server=tcp:', variables('sqlserverName'), '.database.windows.net,1433;Initial Catalog=', variables('databaseName'), ';Persist Security Info=False;User ID=', parameters('sqlAdministratorLogin'), ';Password=', parameters('sqlAdministratorLoginPassword'), ';MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;')]"
            }
          ],
          "appSettings": [
            {
              "name": "WEBSITE_RUN_FROM_PACKAGE",
              "value": "1"
            },
            {
              "name": "AppSettings:ApiRootUrl",
              "value": "[concat('https://', variables('apiApp'), '.azurewebsites.net')]"
            },
            {
              "name": "ASPNETCORE_ENVIRONMENT",
              "value": "Release"
            }
          ]
        }
      }
    }

```

## **Deploying the Application to Azure App Services**

The last step is deploying the application to Azure App Services. Azure App Services supports various deployment mechanisms from simple FTP and git deployments to the recommended zip deploy.

We are using the Azure CLI for deployment and specifically the **az webapp deployment** command.

```powershell

  az functionapp deployment source config-zip -g $resourceGroup -n $webAppName --src $webPackage

```

> **TIP:** Occasionally deployments fail when executed directly after a new site is provisioned. ¯\_(ツ)_/¯ . Simply rerun the deployment command again. In the case of the deployment script it creates an exact output command for you just in case!

[resourceDiagram]: ../../images/labs/azure_resource_diagram.png "Resource Diagram"
[deploymentOutput]: ../../images/labs/app_service_deployment.png "Deployment Output"
[appServiceResources]: ../../images/labs/app_service_resources_portal.png "appServiceResources"
[appServiceUrl]: ../../images/labs/app_service_url.png "appServiceUrl"
[scpSite]: ../../images/labs/second_chance_parts_site.png "scpSite"
[scpFlowmap]: ../../images/labs/second_chance_parts_flowmap.png "scpSite"
[extension1]: ../../images/labs/site_extensions_1.png "extension1"
[extension2]: ../../images/labs/site_extensions_2.png "extension2"
[extension3]: ../../images/labs/site_extensions_3.png "extension3"
[extension4]: ../../images/labs/site_extensions_4.png "extension4"
[extension5]: ../../images/labs/site_extensions_5.png "extension5"
[extension6]: ../../images/labs/site_extensions_6.png "extension6"
[kuduHome]: ../../images/labs/kudu_home.png "kuduHome"
[kuduLog]: ../../images/labs/kudu_log.png "kuduLog"
[kuduAgentFiles]: ../../images/labs/kudu_agent_files.png "kuduAgentFiles"
[kuduProcesses]: ../../images/labs/kudu_processes.png "kuduProcesses"
[kuduProcessModules]: ../../images/labs/kudu_process_module.png "kuduProcessModules"
[zipDeploy]: ../../images/labs/zip_deploy.png "zipDeploy"
[siteHome]: ../../images/labs/app_service_site_home.png "siteHome"
[siteCheckout]: ../../images/labs/app_service_site_checkout.png "siteCheckout"
