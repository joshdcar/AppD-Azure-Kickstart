# Azure Functions Lab

![functionFlowmap][functionFlowmap]

# Lab Scenerio

With a quickly growing business Second Chance Parts is looking for additional opportunities to improve their online e-commerce platform and better manage the quickly growing complexity of the their business. An ever increasing amount of complex activity takes place during order processing. The Second Chance Parts team thinks breaking the complexity into micrservices is a great place to start but would like to take it a step further by an embracing an event based messaging architecture and use the advantages the cloud provides to scale on demand.   Additionally they require a flexible schema backend data store that is highly scalable and can be developed and maintained independantly of the rest of the platform to offer the most amount of flexibility. They have identified Azure Functions, Service Bus, and CosmosDB as the perfect cloud native platform combination to meet their needs.

In this lab we will implement the new order processing function with Azure Functions and configure AppDynamics to monitor that end to end workload that now includes Azure Functions and CosmosDB using the MongoDB API.  

## Lab Primary Objectives

* Provision Azure Functions through the Azure CLI
* Provision CosmosDB and Service Bus Topic Subscriptions through the Azure CLI
* Deploy the application components to Azure Functions
* Deploy, Configure, and Validation\Troubleshoot the AppDynamics Agent 

## Tech Stack

* Azure Functions 3
* .Net Core 3.1
* Azure Service Bus Topic Subscription
* CosmosDB (over MongoDB API) 


# Azure Functions Overview

[Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) allows you to run small pieces of code (called "functions") without worrying about application infrastructure. With Azure Functions, the cloud infrastructure provides all the up-to-date servers you need to keep your application running at scale. 

Azure Functions is part of the Azure App Service family and inherits many of it's features, functionality, and configuration. Azure Functions also has open source core tools and runtimes so it can also be run on other platforms, most typically Kubernetes, both on-premise and in the cloud. Although the Azure Functions runtime is based on .Net Core it supports various languages including Java, Node, Python, and Powershell.

Azure Functions is an events based platform.  For many customers this is typically http and timer based events but also very common storage queues, service bus queues and topics, event hubs and numerous other events.  Central to Azure Functions are the concepts of [triggers and bindings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings).  Triggers are associated with the events previously mentioned and mindings provided simplified methods for interacting with common platforms on Azure such as Service Bus, Azure Storage (Blobs,Storage, Queues), etc. It's worth mentioning that the underlying implementation of these bindings are the standard 

## Azure Functions and AppDynamics

AppDynamics will automatically detect HttpTriggers, TimerTriggers, QueueTriggers, and ServiceBusTriggers as Business Transactions.  AppDynamics will provide end to end visibility and distributed tracing as you would expect through HttpTriggers and ServiceBusTriggers. Additional triggers not supported by default can be configured with custom entry points.

> **NOTE:**  Azure Storage Queues are very common on Azure Functions but unfortunatly do not support distributed tracing.  This is a current limitation of Azure. The platform lacks any location to store distributed tracing tokens. Custom correlation is only possibly by modifying the message payload to include addition distributed tracing data.

The Site Extensions concept for deploying agents on Application Insights has also recently been extended for work with Azure Functions as well.  AppDynamics Agents can be packaged with the application or through the Site Extensions.  This lab will cover the deployment using the latter technique. 

> **TIP** [Durable Functions](https://docs.microsoft.com/en-us/azure/azure-functions/durable/durable-functions-overview?tabs=csharp) and [Durable Entities](https://docs.microsoft.com/en-us/azure/azure-functions/durable/durable-functions-entities?tabs=csharp) are a popular native extension to Azure Functions that provides a workflow and orchestration framework on top of Azure Functions.  Durable Functions make use of the open source Durable Task Framework and are implemented using additional triggers and bindings and a combination of Table Storage and Storage Queues behind the scenes. Defining custom entry points for these durable functions activities can provide some visibility into Durable Functions.

## Lab Steps

## **Step #1** - Azure Resource & Application Deployment

### **Azure Resources Being Deployed**

The following Azure Resources will be deployed as part of this step:
  
  * Azure Function App Service Plan
  * Azure Function App
  * Service Bus Topic Subscription
  * CosmosDB Account
  * CosmosDB Database
  * CosmosDB Collection

![functionDiagram][functionDiagram]

> **TIP:** This diagram created using Lucid Charts. Lucid Charts has native Azure and Cloud icons that are helpful when creating Azure Architecture Diagrams. 

### **Deployment Script**
The Azure Functions Lab contains a single unified powershell script found within your project under **/labs/azure-functions/deploy/azure-deploy.ps1** that performs the following actions:

1. Compile and packaging of the the SecondChanceParts Functions into a zip file format 

2. Provisioning of Azure resources using the Azure CLI.

3. Deployment of the packaged components to the Azure Functions using a [zip deploy](https://docs.microsoft.com/en-us/azure/azure-functions/deployment-zip-push). 


### Executing the Deployment Script

From a terminal window navigate to your workshop project folder and the **/labs/azure-functions/deploy** folder and execute the following command.

> **Windows**  
``` > pwsh .\azure-deploy.ps1```

> **Mac**  
``` > pwsh ./azure-deploy.ps1```

> **DEEP DIVE:** Interested in understanding more about how this script works with the Azure CLI? Jump to **[DEEP DIVE - Better Understanding Deploying Azure Resources with the Azure CLI](#understandingdeploy)** for more details!

### **Expected Output**

The execution of this command should reflect something similiar to the following image. 

![deploymentOutput][deploymentOutput]

> **TIP:** If you get an errors during the execution ensure that you have correctly installed all the workshop prerequisites.  It is not uncommon to see deployment errors during the deployment. If this is the case review the output of the script for deployment commands that can be executed again.

### **Validate Azure Resource Deployment**

Validate that your azure resources are deployed by logging into the Azure Portal and opening your resource group.

![appServiceResources][appServiceResources]

### **Check your Website**

Verify that the web site is up and running by visiting it in your browser. You can find your websites URL in the portal by opening the **appd-scp-web** labeled app service resource. 

![appServiceUrl][appServiceUrl]

#### Verify the site is running. Start shopping by entering a name and selecting "Start Shopping"

![scpSite][scpSite]


<br><br><br>

# **DEEP DIVE** Better Understanding Deploying Azure Resources with the Azure CLI 
<a name="understandingdeploy"></a>




[functionFlowmap]: ../../images/labs/function_flowmap.png "functionsFlowmap"
[functionDiagram]: ../../images/labs/function_resource_diagram.png "functionDiagram"