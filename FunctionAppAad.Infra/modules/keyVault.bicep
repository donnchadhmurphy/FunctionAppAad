@minLength(3)
@maxLength(24)
@description('Resource name for Key Vault')
param resourceName string

@description('Envrionment name')
@allowed([
  'stag'
  'prod'
])
param env string

@description('Access policy AAD object ids. Can be ids for UPN or SPN. Basic read perms for Key, Secret, & Certificate Management.')
param accessPolicyAadObjectIds array

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: resourceName
  location: resourceGroup().location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: env == 'stag' ? 'standard' : 'premium'
    }
    accessPolicies: [ for accessPolicyObjectId in accessPolicyAadObjectIds: {
      tenantId: subscription().tenantId
      objectId: accessPolicyObjectId
      permissions: {
        keys: [
          'get'
          'list'
          'update'
          'create'
          'import'
          'delete'
          'recover'
          'backup'
          'restore'
        ]
        secrets: [
          'get'
          'list'
          'set'
          'delete'
          'recover'
          'backup'
          'restore'
        ]
        certificates: [
          'get'
          'list'
          'update'
          'create'
          'import'
          'delete'
          'recover'
          'backup'
          'restore'
          'managecontacts'
          'manageissuers'
          'getissuers'
          'listissuers'
          'setissuers'
          'deleteissuers'
        ]
      }
    }]
    vaultUri: 'https://${resourceName}${environment().suffixes.keyvaultDns}/'
    enabledForTemplateDeployment: true
    enablePurgeProtection: true
  }
}
