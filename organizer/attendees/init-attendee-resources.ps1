$ErrorActionPreference = "Stop"

#---------------------------------------------------------------------------------------------------
# Initialize Workshop Attendee Resources
#
# This script will initialize users  
#
# NOTE: Consider region caps for your subscription carefully
#       when setting region for attendees to not go over this cap.  Current workshop VCPU Usage
#       Includes:
#       Controller: (2)
#       Azure App Services Lab: (2)
#       Azure Extension Lab: (1)
#       Optional Utility VM (Analytics/DBAgent): (1)
#
# SUGGESTION: Consider requesting additional capacity for regions prior to workshop. Additional details
#             visit https://docs.microsoft.com/en-us/azure/azure-portal/supportability/resource-manager-core-quotas-request
#
# WARNING:  The controller image must be deployed to each region you are deploying resource groups to
#---------------------------------------------------------------------------------------------------

$domain = "appdcloud.onmicrosoft.com"
$controllerPassword = "welcome1"
$githubRepoUrl = "https://github.com/joshdcar/AppD-Azure-Kickstart"
$vmusername = "appdadmin"
$sharedPassword = "AppDynamicsR0ck$!"
$subscriptionId = "b8d08f39-3950-4c72-9c2e-71491e10ccf6"
$controllerVmSize = "Standard_D2S_v3" # 2 core 7gb RAM | Demo Controller Spec Equivilent 
$launchpadVMSize = "Standard_D2S_v3" #Must be series that supports nested VMs (2 CPU - 8GB RAM)

az account set --subscription $subscriptionId

#Get Environment Configuration
[array]$attendees = Get-Content ./attendees.json | ConvertFrom-Json 

#Get Shared Image Gallery ID
$imageGallery = az sig show --resource-group "workshop-resources" --gallery-name "Azure_Workshops_Images" --query id

foreach($attendee in $attendees) {
    
    Write-Host ("Processing Attendee: $($attendee.FirstName) $($attendee.LastName)") -ForegroundColor Green

    #Create AD Account
    $userPrincipal = "$($attendee.FirstName).$($attendee.LastName)@$domain"
    $displayName = "$($attendee.FirstName) $($attendee.LastName)"
    $email = "$($attendee.email)"

    #Check if user already exists
    [array]$existingUsers = az ad user list --upn "$userPrincipal" -o tsv

    if ($existingUsers.Length -eq 0) {

        az ad user create --display-name $displayName `
                  --password $sharedPassword `
                  --user-principal-name $userPrincipal `
                  --force-change-password-next-login false `
                  --only-show-errors `
                  --output none `

        Write-Host ("User Created: $userPrincipal") -ForegroundColor Green

    }
    else {
        Write-Host ("User $userPrincipal already exists.") -ForegroundColor Yellow
    }
    
    #Create Resource Group & Resource Group Tags
    $resourceGroup = "azure-workshop-$($attendee.FirstName)-$($attendee.LastName)".ToLower()
    $location = $($attendee.Region)
    az group create -n $resourceGroup -l $location --output none

    Write-Host ("Resource Group Created: $resourceGroup") -ForegroundColor Green

    $today = Get-Date -Format "MM/dd/yyyy"
    az group update -n $resourceGroup --tags "Workshop=true" "Created=$today" "OwnerEmail=$email" --output none
    Write-Host ("Resource Group Tags Added: Workshop=true, Created=$today") -ForegroundColor Green

    #Assign Permissions to Resource Group
    az role assignment create --role "Owner" --assignee $userPrincipal --resource-group $resourceGroup --output none
    Write-Host ("Owner Role Assigned to $userPrincipal") -ForegroundColor Green

    #Assign Permissios to Shared Resource Group
    az role assignment create --role "Reader" --assignee $userPrincipal --scope $imageGallery
 
    $vmname="appd-controller-vm"

    #Create Controller VM
    az vm create `
        --resource-group $resourceGroup `
        --name $vmname `
        --image "/subscriptions/$subscriptionId/resourceGroups/workshop-resources/providers/Microsoft.Compute/galleries/Azure_Workshops_Images/images/Azure_Workshop_Controller_Image/versions/1.0.1" `
        --size $controllerVmSize `
        --admin-username $vmusername  `
        --os-disk-size-gb 100 `
        --nsg-rule SSH `
        --ssh-key-value "../../environment/shared/keys/appd-azure-cloud-kickstart.pub" `
        --output none

    #Add 8090 Port Rule for NSG (NSG Name is by convention)
    $nsgname = -join($vmname, "NSG") 

    az network nsg rule create `
        --resource-group $resourceGroup `
        --nsg-name $nsgname `
        --name http `
        --access allow `
        --protocol Tcp `
        --direction Inbound `
        --priority 300 `
        --source-address-prefix "*" `
        --source-port-range "*" `
        --destination-address-prefix "*" `
        --destination-port-range 8090 `
        --output none

    #Get the Controller VM Public IP Address
    $controllerIpAddress = az vm show -d -g $resourceGroup -n $vmname --query publicIps -o tsv

    Write-Host ("Controller VM created at IP $controllerIpAddress") -ForegroundColor Green

    #Create the Extension VM

    $extensionVMName = "appd-azure-extensions-vm"

    az vm create `
    --resource-group $resourceGroup `
    --name $extensionVMName `
    --image "/subscriptions/$subscriptionId/resourceGroups/workshop-resources/providers/Microsoft.Compute/galleries/Azure_Workshops_Images/images/Azure_Workshop_AzureExtensions_Image/versions/1.0.0" `
    --size $controllerVmSize `
    --admin-username $vmusername  `
    --os-disk-size-gb 100 `
    --nsg-rule SSH `
    --ssh-key-value "../../environment/shared/keys/appd-azure-cloud-kickstart.pub" `
    --output none

    $extensionIpAddress = az vm show -d -g $resourceGroup -n  $extensionVmName --query publicIps -o tsv

    Write-Host ("Extension VM created at IP $extensionIpAddress") -ForegroundColor Green

    #Create launchpad VM
    
    $launchpadVmName="appd-launchpad"

    az vm create `
        --resource-group $resourceGroup `
        --name  $launchpadVmName `
        --image "/subscriptions/$subscriptionId/resourceGroups/workshop-resources/providers/Microsoft.Compute/galleries/Azure_Workshops_Images/images/Azure_Workshop_LaunchPad_Image/versions/1.0.0"  `
        --size $launchpadVMSize `
        --admin-username $vmusername  `
        --admin-password $sharedPassword `
        --nsg-rule RDP `
        --output none

    #Get the Launchpad VM Public IP Address
    $launchpadIpAddress = az vm show -d -g $resourceGroup -n  $launchpadVmName --query publicIps -o tsv

    Write-Host ("LaunchPad VM created at IP $launchpadIpAddress") -ForegroundColor Green

    #Create Service Principal for use by the extension with a scope limited to the user's resource group
    $appName = "appd_sp_$($attendee.FirstName)_$($attendee.LastName)".ToLower()
    $scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup"
    $servicePrincipal = az ad sp create-for-rbac -n $appName --role Reader --scopes $scope
    $clientName = $servicePrincipal.name
    $clientSecret = $servicePrincipal.clientSecret

    Write-Host ("Service Principal Created") -ForegroundColor Green

    $attendeeConfig = @{
        SubscriptionId = $subscriptionId
        AzureResourceGroup = $resourceGroup
        Region = $($attendee.Region)
        DotnetAgentVMPassword = $sharedPassword
        DotnetAgentVMUsername = $vmusername
        servicePrincipal = $clientName 
        clientSecret = $clientSecret 
        } | ConvertTo-Json | Out-File "./attendee-files/config_$($attendee.Firstname)_$($attendee.Lastname).json"

    $attendeeWelcome = @"

        Hello $($attendee.FirstName),

        We are looking forward to you joining us on our upcoming AppDynamics Cloud Kickstart for Azure.  The following are some details that you will need for the workshop. You can find additional instructions for the workshop at $githubRepoUrl.

        Please note the following details about your workshop environment:

        Azure Subscription ID: $($subscriptionId)
        Azure Region: $($attendee.Region)
        Azure Resource Group: $resourceGroup

        Azure Login Details:
        Username: $userPrincipal
        Password: $sharedPassword

        Controller VM Details:
        Url: http://$($controllerIpAddress):8090
        Username: admin
        Password: $controllerPassword
        ** Use Attached Key File (appd-azure-cloud-kickstart.pem) for SSH Access

        Launchpad VM Details (Preconfigured Windows 10 Workshop Lab Environment):
        IP Address: $launchpadIpAddress
        username: $vmusername
        password: $sharedPassword
        (access the VM over RDP with the above credentials)

        Azure Extension Login Details:
        IP Address: $extensionIpAddress
        username: $vmusername
        ** Use Attached Key File (appd-azure-cloud-kickstart.pem) for SSH Access

        Service Principal for use with AppDynamics Extensions:
        $servicePrincipal 
        
        Subscription ID (used with extensions): 
        $subscriptionId

    Additional details for validating your account and and workshop prerequisites can be found at $githubRepoUrl.
     
"@ | Out-File "./attendee-files/config_$($attendee.Firstname)_$($attendee.Lastname).txt"

    Write-Host ("Attendee Configuration Written (config_$($attendee.Firstname)_$($attendee.Lastname).json)") -ForegroundColor Green
    Write-Host ("Attendee Configuration Written (config_$($attendee.Firstname)_$($attendee.Lastname).txt)") -ForegroundColor Green
}



