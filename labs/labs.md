# Workshop - Getting Started

**Before continuing please confirm you have installed all the [pre-requisites](labs-prereqs.md) for the workshop.**

## Clone This Workshop Github Repository

The Azure Cloud Workshop is maintained here on github as a git repository . Before starting the workshop you should clone this repository so you have it locally on your computer. ([What is cloning?](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)).

### **git command line**

```Powershell
command prompt: git clone https://github.com/joshdcar/AppD-Azure-Kickstart
```

### **Visual Studio Code**

Visual Studio Code also has built in integration with git.

1. Open Visual Studio Code
2. Select the Source Code Icon
3. Choose Clone Repository
4. Enter the Url of the workshop github repo
5. Enter a local location for your repo

 ![Git Clone][gitClone]

Once cloned open the **appd-azure-cloud-workshop.code-workspace** file with Visual Studio Code. Confirm you see a directory structure similar to the image below with Visual Studio Code.

If you open the folder and not the workspace you will get a prompt similar to the below:

![Workspace][workspace]

## Copy Workshop Config File

Before getting started with the lab confirm you have access to the workshop's Azure subscription with the account credentials json file provided by your workshop organizer.

![Config File][configfile]

Please take note of the **Azure login credentials** (Username and password) and the **Controller details** (Controller IP Address, ControllerUsername, and ControllerPassword) as you will need to use these throughout the workshop.

Copy the contents of the config json file into the config.json file located in the environment folder of your local cloned copy of the workshop repository.

![Config File][configLocation]

## Confirm Azure Access

Confirm that you have access to Azure both through the standard portal but also through each of the tools which have slightly different ways of authenticating but all make use of the same login credentials.

> **WARNING:** It is often the case that you may have  multiple Microsoft or Active Directory organization logins in your browser profile. Ensure you are not logging in with any of these previous profiles automatically. You may find it helpful to create an additional dedicated profile in your browser such as Chrome to avoid login\session conflicts.

### **Azure Portal**

1. Visit [portal.azure.com](https://portal.azure.com)

2. Login using the credentials provided by the workshop coordinator.

    ![microsoftLogin][microsoftLogin]

3. Confirm both access to the azure portal and also that you are seeing your default resource group and the appd controller virtual machine is present within the resource group.

    ![azurePortalRg][azurePortalRg]

### **Azure CLI**

1. Open a command prompt (windows) or terminal (mac).
2. Enter ``` az login ``` at the prompt
3. A browser window will be opened for a login. If you have the previous browser session open simply select your login to automatically login with that account.
    ![azureCliLogin][azureCliLogin]
4. Confirm you have successfully logged in with Azure CLI.
    ![azureCliLoginConfirm][azureCliLoginConfirm]

5. Confirm expected subscription details in the console.

    ![azureCliLoginPrompt][azureCliLoginPrompt]

> **Info:** This login process stores a cached version of your access token. This generally expires in 90 days but may expire earlier in some scenarios.

### **Azure Powershell**

1. Open a powershell prompt. This can be done directly or by entering pwsh at the terminal\command prompt.
2. Enter ``` connect-AzAccount ``` at the prompt. Follow the instructions to the website and take note of the code

   ![azurePsPrompt][azurePsPrompt]
3. Enter the code into your browser window

   ![azurePsCode][azurePsCode]

4. Confirm successful login
   ![azurePsResult][azurePsResult]

## Confirm AppDynamics Controller Access

1. Open a browser and navigate to the the ip address of the controller provided by the organizer
2. Login with the provided controller credentials.
3. Confirm the controller is running and take note of your agent keys for future use.

   ![controllerLicense][controllerLicense]

> **TIP**: The workshop controllers are fairly low power virtual machines. Initial startup times may vary and lead to initial timeouts. If timeouts persist confirm that the Network Security Group access policy is in place for port 8090.

## Labs

This workshop consists of several labs with both primary, secondary , and bonus objectives.

| Lab   |      Primary Objective     |  Secondary Objective |  Bonus Objective |
|----------|:-------------|:------|:------|
| [Azure App Services](app-services/azure-app-service-monitoring.md) |  Deploying Agents via Site Extensions | Provision Resources w/ ARM Templates | Configure Analytics |
| [Azure Monitor Extensions](azure-extensions/azure-extensions.md) |    Configure Azure Monitor   | Provision Resources w/ Azure CLI | Monitor Multiple Resources |
| [Azure Functions](azure-functions/azure-functions.md) | Deploying Agents via Site Extensions | Provision Resources w/ Powershell | SQL & CosmosDB Metrics |
| Azure Kubernetes Services (AKS) **Coming Soon**. | Deploy Cluster Agent |    kubectl with AKS |  |

[configfile]: ../images/labs/Config_File_Sample.png "Config File"
[configLocation]: ../images/labs/Config_File_Location.png "Config File Location"
[gitClone]: ../images/labs/git_clone.png "Git Clone"
[workspace]:../images/labs/open_workspace.png "Open Workspace"
[microsoftLogin]:../images/labs/microsoft_login.png "Microsoft Login"
[azurePortalRg]:../images/labs/azure_portal_rg.png "Azure Portal Resource Group"
[azureCliLogin]:../images/labs/azure_cli_login.png "Azure CLI Login"
[azureCliLoginConfirm]:../images/labs/azure_cli_login_confirm.png "Azure CLI Login Confirm"
[azureCliLoginPrompt]:../images/labs/azure_cli_login_prompt.png "Azure CLI Login Confirm Prompt"
[azurePsPrompt]:../images/labs/azure_ps_prompt.png "Azure Powershell Prompt"
[azurePsCode]:../images/labs/azure_ps_code.png "Azure Powershell Code"
[azurePsResult]:../images/labs/azure_ps_result.png "Azure Powershell Result"
[controllerLicense]:../images/labs/controller_license.png "Controller License"
