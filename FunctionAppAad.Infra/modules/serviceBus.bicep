@minLength(6)
@maxLength(50)
@description('Resource name for Service Bus')
param resourceName string

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: resourceName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {}
}

output serviceBusNamespaceName string = serviceBusNamespace.name
