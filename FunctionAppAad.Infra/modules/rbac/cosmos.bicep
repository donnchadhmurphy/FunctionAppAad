@minLength(1)
@maxLength(127)
@description('The principal ID assigned to the role. This maps to the ID inside the Active Directory. It can point to a user, service principal, or security group.')
param principalId string

@description('Unique name for the roleAssignment in the format of a guid')
param resourceName string

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' existing = {
  name: resourceName
}

var roleName = 'Read Write'
resource cosmosReadWriteRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-06-15' = {
  parent: cosmosAccount
  name: guid(roleName)
  properties: {
    roleName: roleName
    assignableScopes: [
      cosmosAccount.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
        ]
        notDataActions: []
      }
    ]
  }
}

resource cosmosReadWriteAppAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-06-15' = {
  parent: cosmosAccount
  name: guid(principalId, cosmosReadWriteRoleDefinition.id, resourceGroup().id)
  properties: {
    principalId: principalId
    roleDefinitionId: cosmosReadWriteRoleDefinition.id
    scope: cosmosAccount.id
  }
}
