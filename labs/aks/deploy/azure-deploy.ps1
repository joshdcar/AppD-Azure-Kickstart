#Utility function to give us some random values (like UniqueString() in ARM Templates)
function Get-RandomCharacters($length, $characters) { 
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length } 
    $private:ofs="" 
    return [String]$characters[$random]
}
#Get Environment Configuration (join-path for multiplatform path support)
$configPath = join-path "../../../environment" -ChildPath "config.json"
$config = Get-Content $configPath | ConvertFrom-Json

Write-Host ("Current Configuration:") -ForegroundColor Green
Write-Host (-join("Resource Group: ", $config.AzureResourceGroup)) -ForegroundColor Green

#Get Environment Configuration (join-path for multiplatform path support)
$configPath = join-path "../../../environment" -ChildPath "config.json"
$config = Get-Content $configPath | ConvertFrom-Json

$resourceGroup = $config.AzureResourceGroup
$region = $config.Region
$servicePrincipalId = $config.servicePrincipal
$clientSecret = $config.clientSecret
$random = Get-RandomCharacters -length 5 -characters 'abcdefghiklmnoprstuvwxyz'
$clusterName = "appd-sp-aks-$random"
$registryName="appdspcr$random"
$nodeVMSize = "Standard_B2ms"

$aksResourceGroup = "$resourceGroup-aks"

$registryId = $(az acr create `
    --resource-group $resourceGroup `
    --name $registryName `
    --sku "Basic" `
    --query id `
    --output tsv)
Write-Host ("Azure Container Registry Created with ID $registryId") -ForegroundColor Green

az aks create `
    --resource-group $resourceGroup `
    --name $clusterName `
    --service-principal $servicePrincipalId `
    --client-secret $clientSecret `
    --node-vm-size $nodeVMSize `
    --node-count 1 `
    --ssh-key-value ../../../environment/shared/keys/appd-cloud-kickstart-azure.pub `
    --node-resource-group $aksResourceGroup `
    --location $region
Write-Host ("AKS Cluster Created") -ForegroundColor Green

az role assignment create `
    --assignee $servicePrincipalId `
    --scope $registryId `
    --role acrpull
Write-Host ("Service Principal assigned Pull rights to the container registry") -ForegroundColor Green

az aks get-credentials `
    --resource-group $resourceGroup `
    --name $clusterName
Write-Host ("Get Credentials to work with local kubectl") -ForegroundColor Green


