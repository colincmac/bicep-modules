param location string = resourceGroup().location
param certName string
param subject string
param vaultName string
param secretTags object = {}
param identityId string = ''
param monthsValid int = 12
param timestamp string = utcNow()
param containerGroupName string = ''

resource addOrGetCert 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'addOrCreateSecret${certName}'
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

    arguments: ' -certName ${certName} -vaultName ${vaultName} -subject ${subject} -monthsValid ${monthsValid}  -tagString \\"${secretTags}\\"'

    scriptContent: loadTextContent('./addOrGetCert.ps1')
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT1H'
    forceUpdateTag: timestamp
    containerSettings: empty(containerGroupName) ? null : {
      containerGroupName: containerGroupName
    }
  }
}

output deployedSecrets object = addOrGetCert.properties.outputs.secrets
