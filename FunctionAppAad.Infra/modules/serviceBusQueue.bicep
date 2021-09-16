@minLength(1)
@maxLength(260)
@description('Resource name for Service Bus Queue')
param resourceName string

param serviceBusNamespaceName string

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2017-04-01' = {
  name: '${serviceBusNamespaceName}/${resourceName}'
  properties: {}
}
