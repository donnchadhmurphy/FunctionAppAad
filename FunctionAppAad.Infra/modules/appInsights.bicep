@minLength(2)
@maxLength(64)
@description('Resource name for Application Insights')
param resourceName string

@description('Envrionment name')
@allowed([
  'stag'
  'prod'
])
param env string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: resourceName
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
  }
  tags: {
    Environment: env == 'stag' ? 'Staging' : 'Production'
  }
}

output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
