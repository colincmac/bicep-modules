param accountName string
param dbName string
@metadata({
  name: 'events'
  tags: {}
  partitionKey: '/partitionKey'
  uniquePaths: []
})
param containerDefs array = [
  {
    name: 'events'
    tags: {}
    partitionKey: '/partitionKey'
    uniquePaths: []
  }
  {
    name: 'solution'
    tags: {}
    partitionKey: '/partitionKey'
    uniquePaths: []
  }
]

resource cosmosAcct 'Microsoft.DocumentDB/databaseAccounts@2020-06-01-preview' existing = {
  name: accountName
}

resource db 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' = {
  name: dbName
  parent: cosmosAcct
  properties: {
    resource: {
      id: dbName
    }
  }
  resource containers 'containers' = [for c in containerDefs: {
    name: c.name
    tags: c.tags
    properties: {
      resource: {
        id: c.name
        partitionKey: {
          paths: [
            c.partitionKey
          ]
          kind: 'Hash'
        }
      }
    }
  }]
}
