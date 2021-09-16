@minLength(3)
@maxLength(44)
@description('Resource name for Database account')
param resourceName string

@description('Envrionment name')
@allowed([
  'stag'
  'prod'
])
param env string

@minLength(1)
@maxLength(128)
@description('Resource name for Database')
param databaseResourceName string

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' = {
  name: resourceName
  location: resourceGroup().location
  tags: {
    Environment: env == 'stag' ? 'Staging' : 'Production'
  }
  properties: {
    analyticalStorageConfiguration: {
      schemaType: 'WellDefined'
    }
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: 'West Europe'
        failoverPriority: 0
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    defaultIdentity: 'FirstPartyIdentity'
    disableLocalAuth: false
  }
}

resource sqlDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-06-15' = {
  name: '${databaseAccount.name}/${databaseResourceName}'
  properties: {
    resource: {
      id: databaseResourceName
    }
  }
}

output primaryMasterKey string = databaseAccount.listKeys().primaryMasterKey
output documentEndpoint string = databaseAccount.properties.documentEndpoint
output fullSqlDatabaseName string = sqlDatabase.name
output databaseName string = sqlDatabase.properties.resource.id
