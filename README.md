
# AppDynamics Cloud Kickstart - Azure

Welcome to the AppDynamics Cloud Kickstart workshop for Microsoft Azure. In this workshop you will learn how to monitor cloud native workloads in Azure with AppDynamics. Along the way you'll be introduced to various tools and techniques that are very commonly used by Azure customers today from Visual Studio Code and the Azure CLI to Powershell and ARM Templates. The lab also includes all source code for applications being deployed to Azure as well.

## Overview

This project contains several labs that will take you through the process of deploying and provisioning cloud native resources and configuring monitoring with AppDynamics for those resources. Each lab will expose you to different methods of deploying and configuring Azure resources from the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) and [ARM Templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview) to [Azure Powershell](https://docs.microsoft.com/en-us/powershell/azure/?view=azps-3.7.0) and the [Azure Portal](https://portal.azure.com/). 

Azure Resources covered in this workshop include:

* Azure App Services (Web & API Apps)
* Azure Functions (Serverless)
* Azure Kubernetes Service (AKS) (Coming Soon)

Additionally you will learn how to consume [Azure Monitor Metrics](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported) through the AppDynamics Extensions for Azure. Azure Monitor metrics play a key role in getting visibility into cloud native infrastructure fully managed by Azure where traditional AppDynamics agents can not be deploy.

Finally you'll be introduced to some common troubleshooting techniques from confirming and troubleshooting agent deployments to where to find agent logs.

> **_NOTE:_**  Although traditional Virtual Machines (IaaS) will be deployed as part of this workshop for stand alone machine agents we will not be covering monitoring traditional workloads on IaaS which do not differ from traditional non-cloud-native on-premise scenarios.  Additionally each attendee will have an AppDynamics controller deployed to their resource group but deploying and configuring production controllers to Azure is out of scope for this workshop.

## Workshop Delivery

As part of this workshop you will be provided an Azure Active Directory account associated with an Azure Subscription alongside an Azure Resource Group in which all resources deployed as part of your lab will be deployed do. **_You will not need your own subscription for this workshop._**

The workshop coordinate will provide you a configuration file that contains both configuration used by the labs and also your login credentials to the azure portal (and to be used by Powershell & Azure CLI). Further instructions can be found in the various getting started guides.

> **ADVICE:** If you would like to have additional time with the resources or lab material following the workshop consider making a request to your organizer if they can delay deleting your Azure resources and access for a couple days.

## **Getting Started**

### Attendees

Attendees should ensure that they have all the pre-requisites installed prior to starting the labs:

* [Required Lab Prerequisites](./labs/labs-prereqs.md)
* [Configuring Lab Environment](./labs/labs.md)

> ADVICE: Each lab contains helpful links to online learning paths for Azure from Microsoft Learn. Microsoft >Learn is a self-paced, guided, and interactive training site for Microsoft Azure. Microsoft Learn provides a >short lived sandbox Azure subscription as part of their guided lesson.  The entire experience is gamified >so you can earn badges and rewards as you learn more about Azure.  More details available at [Microsoft >Learn](https://docs.microsoft.com/en-us/learn/).

### Organizer

If you're an organizer you can find more details on preparing an Azure subscription for the lab and creating attendee accounts & resources.

* [Organizer Instructions](./organizer/readme.md)


## **Labs**

| Lab   |      Primary Objective     |  Secondary Objective |  Bonus Objective |
|----------|:-------------|:------|:------|
| [Azure App Services (45 minutes)](./labs/app-services/app-services.md) |  Deploying Agents via Site Extensions | Provision Resources w/ ARM Templates | Configure Analytics |
| [Azure Monitor Extensions (45 minutes)](./labs/azure-extensions/azure-extensions.md) |    Configure Azure Monitor   | Provision Resources w/ Azure CLI | Monitor Multiple Resources |
| [Azure Functions (30 minutes)](./labs/azure-functions/azure-functions.md) | Deploying Agents via Site Extensions | Provision Resources w/ Powershell | SQL & CosmosDB Metrics |
| Azure Kubernetes Services (AKS) (45 minutes) **COMING SOON** | Deploy Cluster Agent |    kubectl with AKS |  |
