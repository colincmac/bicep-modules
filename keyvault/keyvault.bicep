param name string
param keyVaultsku string = 'Standard'
param tenantId string
param location string = resourceGroup().location
param tags object = {}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: keyVaultsku
    }
    accessPolicies: []
    tenantId: tenantId
    enabledForDiskEncryption: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}

output keyvaultId string = keyvault.id
