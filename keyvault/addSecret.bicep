@minLength(3)
@maxLength(30)
@description('Specifies the name of the key vault.')
param keyVaultName string

@description('Specifies the name of secret.')
param secretName string

@description('Specifies the value of secret.')
@secure()
param secretValue string

// Todo: refine
resource secret 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  name: '${keyVaultName}/${secretName}'
  properties: {
    value: secretValue
  }
}

output provisionedResourceId string = secret.id
output provisionedResourceName string = secret.name
output secretURI string = secret.properties.secretUri
output secretURIWithVersion string = secret.properties.secretUriWithVersion
output secretValueAdded string = secret.properties.secretUriWithVersion
