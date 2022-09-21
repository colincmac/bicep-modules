param principalId string
param roleGuid string
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: storageAccountName
}

resource role_assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, principalId, roleGuid)
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleGuid)
  }
  scope: storageAccount
}
