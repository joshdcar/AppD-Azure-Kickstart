#Utility function to give us some random values (like UniqueString() in ARM Templates)
function Get-RandomCharacters($length, $characters) { 
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length } 
    $private:ofs="" 
    return [String]$characters[$random]
}

Write-Host ("Current Configuration:") -ForegroundColor Green
Write-Host (-join("Resource Group: ", $config.AzureResourceGroup)) -ForegroundColor Green

# publish the order processing code
dotnet publish -c Release "../src/SecondChanceParts.Functions/SecondChanceParts.Functions.csproj"
$functionsPublishFolder =   "../src/SecondChanceParts.Functions/bin/release/netcoreapp3.1/publish"
Write-Host ("Function Compiled and Published to Folder") -ForegroundColor Green

# create the order processing publish package
$functionsPackage = "scp-functions-deploy.zip"
if(Test-path $functionsPackage) {Remove-item $functionsPackage}
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($functionsPublishFolder, $functionsPackage)
Write-Host ("Publish Folder Compressed for Zip to Deploy") -ForegroundColor Green

#Get Environment Configuration (join-path for multiplatform path support)
$configPath = join-path "../../../environment" -ChildPath "config.json"
$config = Get-Content $configPath | ConvertFrom-Json


$resourceGroup = $config.AzureResourceGroup

$random = Get-RandomCharacters -length 5 -characters 'abcdefghiklmnoprstuvwxyz'
$storageAccount = "appdorderfuncstg"
$appServicePlan = "appd-scp-asp-$random"
$functionApp = "appd-scp-func-$random"
$serviceBus = "appd-scp-sb-$random"
$subscriptionName = "ordersSubscription"
$accountName="cosmos-scp-$random" 
$databaseName='ordersDb'
$collectionName='orders'
$partitionKey="UserStatus"
$region = $config.Region


#Create a storage account for the functions
az storage account create `
    --name $storageAccount `
    --location $region `
    --resource-group $resourceGroup `
    --sku Standard_LRS `
    --output none
Write-Host ("Storage Account Created: $storageAccount") -ForegroundColor Green

#Create an App Service plan (we're not going to use consumption for the lab)
az functionapp plan create `
    --name $appServicePlan `
    --resource-group $resourceGroup `
    --location $region `
    --sku B1 `
    --output none
Write-Host ("Funcation App Plan Created: $appServicePlan") -ForegroundColor Green

# Create a Function App
az functionapp create `
    --name $functionApp `
    --storage-account $storageAccount `
    --plan $appServicePlan `
    --resource-group $resourceGroup `
    --disable-app-insights true `
    --functions-version 3 --output none
Write-Host ("Function App Created: $functionApp") -ForegroundColor Green

# Create a Service Bus Topic Subscription (We want to listen for Checkout Order Events)
$serviceBus = az servicebus namespace list `
    --resource-group "azure-workshop-steven-rogers" `
    --query [0].name `
    -o json
Write-Host ("Get Service Bus Reference: $serviceBus") -ForegroundColor Green

az servicebus topic subscription create `
    --resource-group $resourceGroup `
    --namespace-name $serviceBus `
    --topic-name "OrderTopic" `
    --name $subscriptionName `
    --output none
Write-Host ("Service Bus Topic Created: $subscriptionName") -ForegroundColor Green

#Get Service Bus Connection String
$connectionString=$(az servicebus namespace authorization-rule keys list `
                    --resource-group $resourceGroup `
                    --namespace-name $serviceBus `
                    --name RootManageSharedAccessKey `
                    --query primaryConnectionString `
                    --output tsv)
Write-Host ("Retrieve Service Bus Connection String for $serviceBus") -ForegroundColor Green

#Update Function App Settings 
az functionapp config appsettings set `
    --name $functionApp `
    --resource-group $resourceGroup `
    --settings "ServiceBusConnection=$connectionString" `
    --output none
Write-Host ("Add Service Bus Connection String to Function AppSettings") -ForegroundColor Green

#Create CosmosDB Account
az cosmosdb create `
    -n $accountName `
    -g $resourceGroup `
    --kind MongoDB `
    --default-consistency-level Eventual `
    --locations regionName=$region failoverPriority=0 isZoneRedundant=False `
    --output none `

#Create a MongoDB API Database
az cosmosdb mongodb database create `
    -a $accountName `
    -g $resourceGroup `
    -n $databaseName `
    --output none `

#Create Collection
az cosmosdb mongodb collection create `
    -a $accountName `
    -g $resourceGroup `
    -d $databaseName `
    -n $collectionName `
    --shard $partitionKey `
    --throughput 400 `
    --output none

#Get CosmosDB Connection String
$cosmosConnectionString = $(az cosmosdb keys list `
                            -n $accountName `
                            -g $resourceGroup `
                            --type connection-strings `
                            --query connectionStrings[0].connectionString`
                            --output tsv)

#Update Function App Settings
az functionapp config appsettings set `
    --name $functionApp `
    --resource-group $resourceGroup `
    --settings "CosmosDbConnection=$cosmosConnectionString" `
    --output none
Write-Host ("Add CosmosdB Connection String to Function AppSettings") -ForegroundColor Green

Write-Host("If deployment fails re-run deployment with the following commands:") -ForegroundColor Yellow
Write-Host (-join("az functionapp deployment source config-zip -g ",$resourceGroup," -n ", $functionApp, " --src ", $functionsPackage))

az functionapp deployment source config-zip `
 -g $resourceGroup -n $functionApp --src $functionsPackage
 Write-Host ("Function App Deployed.") -ForegroundColor Green
