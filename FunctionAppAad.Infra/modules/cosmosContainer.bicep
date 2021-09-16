@minLength(1)
@maxLength(128)
@description('Resource name for Database Container')
param resourceName string

@minLength(1)
@maxLength(128)
@description('Resource name for Database')
param databaseName string

param  partitionKey array

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-06-15' = {
  name: '${databaseName}/${resourceName}'
  properties: {
    resource: {
      id: resourceName
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: partitionKey
        kind: 'Hash'
      }
      uniqueKeyPolicy: {
        uniqueKeys: []
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
    }
  }
}

output containerName string = container.properties.resource.id
output containerPrimaryKey string = container.properties.resource.partitionKey.paths[0] // get the first element of paths