@minLength(1)
@maxLength(127)
@description('The principal ID assigned to the role. This maps to the ID inside the Active Directory. It can point to a user, service principal, or security group.')
param principalId string

@description('roleDefinition to apply to the resourceGroup - default is contributor')
param roleDefinitionId string

@description('Unique name for the roleAssignment in the format of a guid')
param resourceName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: resourceName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(principalId, roleDefinitionId, resourceGroup().id)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
  }
}
