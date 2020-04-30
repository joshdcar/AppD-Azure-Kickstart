

[Array]$resourceGroups = az group list --tag "workshop=true" --query "[].name" --output tsv

foreach($group in $resourceGroups) {

    Write-Host ("Deleting $group") -ForegroundColor Green

    az group delete --resource-group $group --only-show-errors --yes # --no-wait

    Write-Host ("$group Deleted") -ForegroundColor Green

}

