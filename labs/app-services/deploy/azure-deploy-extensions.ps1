
#Get Environment Configuration (join-path for multiplatform path support)
$configPath = join-path "../../../environment" -ChildPath "config.json"
$config = Get-Content $configPath | ConvertFrom-Json

Write-Host ("Current Configuration:") -ForegroundColor Green
Write-Host (-join("Resource Group: ", $config.AzureResourceGroup)) -ForegroundColor Green

$resourceGroup = $config.AzureResourceGroup

# Compile & Publish the Web Site 
$webcsproj = join-path "../src/SecondChanceparts.Web" -ChildPath "SecondChanceParts.Web.csproj"
dotnet publish -c Release $webcsproj
$webPublishFolder =  join-path "../src/SecondChanceparts.Web/bin/release/netcoreapp3.1" -ChildPath "/publish"

# Create the Web Site Deployment Package
$webPackage = "secondchanceparts.web.zip"
if(Test-path $webPackage) {Remove-item $webPackage}
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($webPublishFolder, $webPackage) 

# Compile & Publish the Web API
$apicsproj = join-path "../src/SecondChanceparts.Api" -ChildPath "SecondChanceParts.Api.csproj"
dotnet publish -c Release $apicsproj
$apiPublishFolder =  join-path "../src/SecondChanceparts.Api/bin/release/netcoreapp3.1" -ChildPath "/publish" 

# Create the Web API Deployment Package
$apiPackage = "secondchanceparts.api.zip"
if(Test-path $apiPackage) {Remove-item $apiPackage}
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($apiPublishFolder, $apiPackage)

$provisionFile = "azure-deploy-extensions.json"

#Deploy Function + Service Bus Queue w/ ARM Template
[array]$appNames = (az group deployment create `
            --name "appd-azure-deployment" `
             --resource-group $resourceGroup `
             --template-file $provisionFile `
             --parameters @azure-deploy-params.json `
             --query '[properties.parameters.webAppName.value,properties.parameters.apiAppName.value]' -o tsv)

$webAppName = $appNames[0]
$apiAppName = $appNames[1]

Write-Host ("Resources Successfully Deployed") -ForegroundColor Green
Write-Host (-join("Web App Name: ",$webAppName)) -ForegroundColor Green
Write-Host (-join("Api App name: ",$apiAppName)) -ForegroundColor Green

# Use Zip Deploy to Deploy to the Azure Web Applications
# NOTE: Occasionally these do fail so the command is included to re-run if neccesary 
Write-Host("If deployment fails re-run deployment with the following commands:") -ForegroundColor Yellow
Write-Host (-join("az webapp deployment source config-zip -g ",$resourceGroup," -n ", $webAppName, " --src ", $webPackage))
Write-Host (-join("az webapp deployment source config-zip -g ",$resourceGroup," -n ", $apiAppName, " --src ", $apiPackage))

az webapp deployment source config-zip `
 -g $resourceGroup -n $webAppName --src $webPackage

az webapp deployment source config-zip `
 -g $resourceGroup -n $apiAppName  --src $apiPackage 

 Write-Host ("Web Application Deployment Complete") -ForegroundColor Green