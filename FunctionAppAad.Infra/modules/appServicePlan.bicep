@minLength(3)
@maxLength(40)
@description('Resource name for App Service Plan')
param resourceName string

@description('Envrionment name')
@allowed([
  'stag'
  'prod'
])
param env string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: resourceName
  location: resourceGroup().location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  tags: {
    Environment: env == 'stag' ? 'Staging' : 'Production'
  }
}

output appServicePlanId string = appServicePlan.id
