$ErrorActionPreference = "Stop"

$currentLocation = Get-Location

Write-Host ("Current Location: $currentLocation") -ForegroundColor Green

# Do some extra work to ensure we have a cross-platform path to our lab provisioning scripts
$appServiceLab = "../app-services/deploy"
$appServiceLab = [IO.Path]::GetFullPath($appServiceLab)

Write-Host ("Setting Working Location: $appServiceLab") -ForegroundColor Green
Set-Location $appServiceLab

$appServiceLab = Join-Path -Path $appServiceLab -ChildPath 'azure-deploy.ps1'

Write-Host ("Executing App Service Lab Deploy: $appServiceLab") -ForegroundColor Green
.($appServiceLab);
Write-Host ("App Service Lab Deploy Complete") -ForegroundColor Green


# Do some extra work to ensure we have a cross-platform path to our lab provisioning scripts
$azureFunctionsLab = "../azure-functions/deploy"
$azureFunctionsLab = [IO.Path]::GetFullPath($azureFunctionsLab)

Write-Host ("Setting Working Location: $azureFunctionsLab") -ForegroundColor Green
Set-Location $azureFunctionsLab

$azureFunctionsLab = Join-Path -Path $azureFunctionsLab -ChildPath 'azure-deploy.ps1'

Write-Host ("Executing Azure Function Lab Deploy:$azureFunctionsLab") -ForegroundColor Green
.($azureFunctionsLab);
Write-Host ("Azure Function Lab Deploy Complete") -ForegroundColor Green

