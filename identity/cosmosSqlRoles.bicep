@description('Defaults to account level. Ex: `/dbs/<database-name>/colls/<container-name>`')
param scope string = ''
@description('Listed here https://docs.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac#built-in-role-definitions')
param roleDefinitionId string
param principalId string
param cosmosAccountName string

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2021-11-15-preview' existing = {
  name: cosmosAccountName
}

resource sqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-04-15' existing = {
  name: roleDefinitionId
}

resource roleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-11-15-preview' = {
  name: guid(roleDefinitionId, principalId)
  parent: cosmos
  properties: {
    principalId: principalId
    roleDefinitionId: sqlRoleDefinition.id
    scope: empty(scope) ? cosmos.id : '${cosmos.id}/${scope}'
  }
}
