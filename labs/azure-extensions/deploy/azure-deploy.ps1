$ErrorActionPreference = "Stop"

# Get Environment Configuration (join-path for multiplatform path support)
# Additional Instructions https://docs.microsoft.com/en-us/powershell/module/Az.Compute/New-AzVM?view=azps-3.7.0

#Get Workshop Configuration Details
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