param principalId string
param roleGuid string
param keyVaultName string

// https://docs.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations

resource kv 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource role_assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, principalId, roleGuid)
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleGuid)
  }
  scope: kv
}
