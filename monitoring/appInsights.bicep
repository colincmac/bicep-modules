@minLength(3)
@maxLength(260)
param appInsightsName string
param location string = resourceGroup().location
@description('Specifies the name of Key Vault for storing connection string. If not supplied storing of connection string is skipped. Both KeyVaultName and SecretName are required to store connection string in KeyVault.')
param keyVaultName string = ''
@description('Specifies the name of secret in Key Vault for storing connection string.')
param secretName string = ''

@allowed([
  'web'
  'other'
])
param applicationType string = 'web'
param aiWorkSpaceId string = ''

@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForIngestion string = 'Disabled'

@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForQuery string = 'Disabled'

param keyVaultResourceGroupName string = resourceGroup().name

param tags object = {}

var derivedKeyVaultName = 'kv-${keyVaultName}-${secretName}-appInsights'
var kvSecretName = length(derivedKeyVaultName) > 64 ? '${substring(derivedKeyVaultName, 0, 49)}-${uniqueString(keyVaultName, secretName)}' : derivedKeyVaultName

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: applicationType
  tags: tags
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: aiWorkSpaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

module kvAppInsightsSecret '../keyvault/addSecret.bicep' = if (!empty(keyVaultName) && !empty(secretName)) {
  name: kvSecretName
  params: {
    keyVaultName: keyVaultName
    secretName: secretName
    secretValue: appInsights.properties.ConnectionString
  }
  scope: resourceGroup(keyVaultResourceGroupName)
}

output provisionedResourceId string = appInsights.id
output provisionedResourceName string = appInsights.name
output provisionedLocationName string = appInsights.location
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output keyVaultSecretUri string = (!empty(keyVaultName) && !empty(secretName)) ? kvAppInsightsSecret.outputs.secretURI : ''
