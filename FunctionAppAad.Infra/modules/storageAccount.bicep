@minLength(3)
@maxLength(24)
@description('Resource name for Storage Account')
param resourceName string

@description('Envrionment name')
@allowed([
  'stag'
  'prod'
])
param env string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: resourceName
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
    tags: {
    Environment: env == 'stag' ? 'Staging' : 'Production'
  }
}

output storageAccountName string = storageAccount.name
output storageAccountKey string = storageAccount.listKeys().keys[0].value
