param location string = resourceGroup().location
param secretName string
param vaultName string
param secretTags object = {}
param identityId string = ''

// https://docs.microsoft.com/en-us/azure/key-vault/keys/about-keys-details
@allowed([
  'rsa' // RSA: "Software-protected" RSA key
  'ec'
])
@metadata({
  ec: '"Software-protected" Elliptic Curve key'
  rsa: '"Software-protected" RSA key'
})
param keyType string = 'rsa'

@description('If keyType="ec", the curve type to use in generation of the key.')
@allowed([
  'P-256'
  'P-256K'
  'P-384'
  'P-521'
])
param ecType string = 'P-256'

@description('If keyType="rsa", the key size to use in generation of the key.')
@allowed([
  '2048'
  '3072'
  '4096'
])
param rsaSize string = '2048'

param timestamp string = utcNow()

var keyOption = keyType == 'rsa' ? rsaSize : ecType
// TODO: return secret URI's
resource addOrCreateSecret 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'addOrCreateSecret${secretName}'
  location: location
  kind: 'AzurePowerShell'
  identity: empty(identityId) ? {} : {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '3.0'
    arguments: ' -secretName ${secretName} -vaultName ${vaultName} -secretType ${keyType}  -keyOption ${keyOption} -tagString \\"${secretTags}\\"'
    scriptContent: loadTextContent('./addOrGetKey.ps1')
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT1H'
    forceUpdateTag: timestamp
  }
}

output deployedSecrets object = addOrCreateSecret.properties.outputs.secrets
