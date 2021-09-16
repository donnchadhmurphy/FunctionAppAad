// Target resource group scope.
targetScope = 'resourceGroup'

// Environment to deploy to.
// Certain resource values may also differ based on environment, such as SKUs (see other bicep files).
@description('Envrionment name.')
@allowed([
  'stag'
  'prod'
])
param env string // Required to pass in, no default.

// The following variables are used as part of the naming convention we will use:
// [resource type prefix]-[service]-[workload]-[environment]-[region]-[optional]

// Service. Used as part of resource naming convention.
var service = 'env'

// Workload. Used as part of resource naming convention.
var workload = 'faad'

// Workload region.
var region = 'westeu'

// Resource type prefixes based on official guidance. Add more as needed.
// See: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
//      https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules
//      https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
var prefixes = {
  applicationInsights: 'appi'
  appService: 'app'
  appServicePlan: 'plan'
  cosmos: 'cosmos'
  functionApp: 'func'
  storageAccount: 'st'
  serviceBus: 'sb'
  servceBusQueue: 'sbq'
}

// Suffix to be appended to all prefixes.
var resourceSuffix = '-${service}-${workload}-${env}-${region}'

// Storage Account
var storageAccountResourceName = replace('${prefixes.storageAccount}${resourceSuffix}', '-', '') // ex: strenvfaadstagwesteu (Storage Accounts cannot contain hyphens)
module storageAccount 'modules/storageAccount.bicep' = {
  name: 'StorageAccount_${storageAccountResourceName}'
  params: {
    resourceName: storageAccountResourceName
    env: env
  }
}

// Application Insights
var appInsightsResrouceName = '${prefixes.applicationInsights}${resourceSuffix}' // ex: appi-env-faad-stag-westeu
module appInsights 'modules/appInsights.bicep' = {
  name: 'ApplicationInsights_${appInsightsResrouceName}'
  params: {
    resourceName: appInsightsResrouceName
    env: env
  }
}

// Application Service Plan
var appServicePlanResourceName = '${prefixes.appServicePlan}${resourceSuffix}' // ex: plan-env-faad-stag-westeu
module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'AppServicePlan_${appServicePlanResourceName}'
  params: {
    resourceName: appServicePlanResourceName
    env: env
  }
}

// Service Bus
var serviceBusResourceName = '${prefixes.serviceBus}${resourceSuffix}' // ex: sb-env-faad-stag-westus2
module serviceBus 'modules/serviceBus.bicep' = {
  name: 'ServiceBus_${serviceBusResourceName}'
  params: {
    resourceName: serviceBusResourceName
  }
}

// Service Bus Queue
var faadDemoQueueName = '${prefixes.servceBusQueue}-faad-demo' // ex: sbq-faad-demo
module serviceBusQueue 'modules/serviceBusQueue.bicep' = {
  name: 'ServiceBusQueue_${faadDemoQueueName}'
  params: {
    resourceName: faadDemoQueueName
    serviceBusNamespaceName: serviceBus.outputs.serviceBusNamespaceName
  }
  dependsOn: [
    serviceBus
  ]
}

// Cosmos DB
var cosmosResourceName = '${prefixes.cosmos}${resourceSuffix}' // ex: cosmos-env-faad-stag-westus2
module cosmos 'modules/cosmos.bicep' = {
  name: 'Cosmos_${cosmosResourceName}'
  params: {
    env: env
    resourceName: cosmosResourceName
    databaseResourceName: 'FruitDB'
  }
}

// Cosmos DB Container (EvaluationContextStore)
var evaluationContextStoreContainerResourceName = 'FruitStore'
module evaluationContextStoreContainer 'modules/cosmosContainer.bicep' = {
  name: 'CosmosContainer_${evaluationContextStoreContainerResourceName}'
  params: {
    resourceName: evaluationContextStoreContainerResourceName
    databaseName: cosmos.outputs.fullSqlDatabaseName
    partitionKey: [
      '/id'
    ]
  }
  dependsOn: [
    cosmos
  ]
}

// Function App
var functionAppResourceName = '${prefixes.functionApp}${resourceSuffix}' // ex: func-faad-stag-westeu
module functionApp 'modules/functionApp.bicep' = {
  name: 'FunctionApp_${functionAppResourceName}'
  params: {
    resourceName: functionAppResourceName
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    storageAccountName: storageAccount.outputs.storageAccountName
    serviceBusNamespaceName: serviceBus.outputs.serviceBusNamespaceName
    cosmosDBEndpointUrl: cosmos.outputs.documentEndpoint
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    env: env
  }
  dependsOn: [
    appServicePlan
    storageAccount
    appInsights
    serviceBus
    cosmos
  ]
}

var storageBlobDataOwnerRoleDefinitionId = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
module roleAssignmentStorageBlob 'modules/rbac/storageAccount.bicep' = {
  name: 'RoleAssignment_FunctionApp_StorageBlob'
  params: {
    principalId: functionApp.outputs.managedIdentityPrincipalId
    roleDefinitionId: storageBlobDataOwnerRoleDefinitionId
    resourceName: storageAccountResourceName
  }
  dependsOn: [
    storageAccount
  ]
}

var azureServiceBusDataOwnerRoleDefinitionId = '090c5cfd-751d-490a-894a-3ce6f1109419'
module roleAssignmentServiceBus 'modules/rbac/seviceBus.bicep' = {
  name: 'RoleAssignment_FunctionApp_ServiceBus'
  params: {
    principalId: functionApp.outputs.managedIdentityPrincipalId
    roleDefinitionId: azureServiceBusDataOwnerRoleDefinitionId
    resourceName: serviceBusResourceName
  }
  dependsOn: [
    serviceBus
  ]
}


module roleAssignmentCosmos 'modules/rbac/cosmos.bicep' = {
  name: 'RoleAssignment_FunctionApp_Cosmos'
  params: {
    principalId: functionApp.outputs.managedIdentityPrincipalId
    resourceName: cosmosResourceName
  }
  dependsOn: [
    cosmos
  ]
}
