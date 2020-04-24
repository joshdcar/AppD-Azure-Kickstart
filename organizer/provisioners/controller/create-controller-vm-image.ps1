# NOTE: This is a work in progress and really just notes to reproduce creation of the shared image. 
# WARNING: This Script is not intended to be run in it's entirity (yet). 
# Commands following 

 $resourceGroup = "appd-controller-vm-image-3"
 $location = "East US"
 az group create -n $resourceGroup -l $location

 $vmname = "appd-controller-vm"
 $admin = "appdadmin"

$ipaddress = (az vm create `
    --resource-group $resourceGroup `
    --name  $vmname `
    --image OpenLogic:CentOS:7.5:latest `
    --size Standard_D2s_v3 `
    --admin-username $admin  `
    --os-disk-size-gb 100 `
    --ssh-key-value "../environment/shared/keys/AppD-Cloud-Kickstart-Azure.pub" `
    --query 'publicIpAddress' -o tsv)

Write-Host (-join("New IP Address:" ,$ipaddress)) 

$nsgname = -join($vmname, "NSG") 
Write-Host (-join("NSG Name",$nsgname)) 

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
    --destination-port-range 8090`


# We needed to resize the volumn after it's provisioned to use the entire 100GB 
# follow instructions here http://blog.tzachi-networks.com/2018/12/25/azure-linux-vm-expend-centosredhat-7-x-os-disk/ 
# (Azure Docs don't account for OS partition and "in-use" issues. This article works.)
            
Write-Host ("Copy Files and SSH Commands") -ForegroundColor Green
Write-Host (-join("scp -i ../environment/shared/keys/AppD-Cloud-Kickstart-Azure ./install_centos7_appdynamics_enterprise_console.sh ",$admin,"@", $ipaddress, ":.")) 
Write-Host (-join("scp -i ../environment/shared/keys/AppD-Cloud-Kickstart-Azure ./install_centos7_appdynamics_platform_services.sh ",$admin,"@", $ipaddress, ":.")) 
Write-Host (-join("ssh -i ../environment/shared/keys/AppD-Cloud-Kickstart-Azure ",$admin,"@", $ipaddress)) 


# Post Provisioning INSTRUCTIONS
# 1) SSH Set appd_username and appd_password environment variables (export)
# 2) SUDO SU
# 3) RUN install_centos7_appdynamics_enterprise_console.sh
# 4) RUN install_centos7_appdynamcis_platform_services.sh
# 5) Uplaod License File and restart controller process (services)

# NOTE: If you you fail minimum memory checks restart the OS - it can be very close on memory after running #3

Write-Host ("Copy License File After Installing AppDynamics") -ForegroundColor Green
Write-Host (-join("scp -i ../environment/shared/keys/AppD-Cloud-Kickstart-Azure ../environment/license.lic ",$admin,"@", $ipaddress, ":/opt/appdynamics/product/platform/controller")) 


#az vm generalize --resource-group myResourceGroup --name myVM
#az image create  --resource-group myResourceGroup --name myImage --source myVM
