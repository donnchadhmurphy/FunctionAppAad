param principalId string
var roleName = 'Bicep Custom Role'


param functionAppResourceName string

resource functionApp 'Microsoft.Web/sites@2021-01-15' existing = {
  name: functionAppResourceName
}

resource definition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name: guid(roleName)
  properties: {
    roleName: roleName
    description: 'Custom role create with bicep'
    permissions: [
      {
        actions: [
          '*/read'
        ]
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

resource assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(roleName, principalId, resourceGroup().id)
  scope: functionApp
  properties: {
    roleDefinitionId: definition.id
    principalId: principalId
  }
}
