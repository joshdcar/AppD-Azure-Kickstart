#---------------------------------------------------------------------------------------------------
# Initialize Workshop Attendee Resources
#
# This script will initialize users  
#
# The AWS CLI also introduces a new set of simple file commands for efficient file transfers
# to and from Amazon S3.
#
# For more details, please visit:
#   https://aws.amazon.com/cli/
#
# NOTE: By Default Regions are capped at 10 VCPU (Soft limit). Consider Configuration carefully
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
$contollerUsername = "admin"
$controllerPassword = "welcome1"
$githubRepoUrl = "https://github.com/joshdcar/appd-azure-cloud-workshop"
$vmusername = "appdadmin"
$sharedPassword = "AppDynamicsR0ck$!"
$subscriptionId = "d4d4c111-4d43-41b2-bb7f-a9727e5d0ffa"

#Get Environment Configuration
[array]$attendees = Get-Content ./attendees.json | ConvertFrom-Json 


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

    $vmname="appd-controller-vm"

    #Create Controller VM
    az vm create `
        --resource-group $resourceGroup `
        --name $vmname `
        --image "/subscriptions/$subscriptionId/resourceGroups/workshop-resources/providers/Microsoft.Compute/galleries/Azure_Workshop_Images/images/Azure_Workshop_Controller_Image/versions/1.0.0" `
        --size Standard_DS2_v2 `
        --admin-username $vmusername  `
        --os-disk-size-gb 100 `
        --ssh-key-value "../../environment/shared/keys/AppD-Cloud-Kickstart-Azure.pub" `
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

    #Create Service Principal for use by the extension with a scope limited to the user's resource group
    $appName = "appd_sp_$($attendee.FirstName)_$($attendee.LastName)".ToLower()
    $scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup"
    $servicePrincipal = az ad sp create-for-rbac -n $appName --role Reader --scopes $scope

    Write-Host ("Service Principal Created") -ForegroundColor Green

    $attendeeConfig = @{
        AzureResourceGroup = $resourceGroup
        Region = $($attendee.Region)
        DotnetAgentVMPassword = $sharedPassword
        DotnetAgentVMUsername = $vmusername
        } | ConvertTo-Json | Out-File "./attendee-files/config_$($attendee.Firstname)_$($attendee.Lastname).json"

    $attendeeWelcome = @"

    @"
        Hello $($attendee.FirstName),

        We are looking forward to you joining us on our upcoming AppDynamics Cloud Clickstart for Azure.  The following are some details  
        that you will need for the workshop. You can find additional instructions for workshop at $githubRepoUrl.

        Please note the following details you will require for the workshop:

        Azure Region: $($attendee.Region)
        Azure Resource Group: $resourceGroup

        Azure Login Details:
        Username: $userPrincipal
        Password: $sharedPassword

        Controller Details:
        Url: http://$($controllerIpAddress):8090
        Username: admin
        Password: $controllerPassword
        SSH: Enabled (see attached PEM file)
        
        Dotnet Agent Login Details:
        IP Address: Available after provisioning in the lab
        username: $vmusername
        password: $sharedPassword

        Service Principal for use with AppDynamics Extensions:
        $servicePrincipal 
        
        Subscription ID (used with extensions): 
        $subscriptionId

    Additional details for validating your account and and workshop prereqs can be found at $githubRepoUrl.
     
"@ | Out-File "./attendee-files/config_$($attendee.Firstname)_$($attendee.Lastname).txt"

    Write-Host ("Attendee Configuration Written (config_$($attendee.Firstname)_$($attendee.Lastname).json)") -ForegroundColor Green
    Write-Host ("Attendee Configuration Written (config_$($attendee.Firstname)_$($attendee.Lastname).txt)") -ForegroundColor Green
}

