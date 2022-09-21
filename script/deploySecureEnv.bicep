param storageName string = toLower('${take('deployscript${uniqueString(resourceGroup().id)}', 22)}st')
param containerName string = toLower('${take('deployscript${uniqueString(resourceGroup().id)}', 22)}ci')
param subnetId string
param identityId string
@description('Specify which type of dev environment to deploy')
@allowed([
  'AzureCLI'
  'AzurePowerShell'
])
param type string = 'AzureCLI'

@description('Use to overide the version to use for Azure CLI or AzurePowerShell')
param toolVersion string = ''

@description('This is the path in the container instance where it\'s mounted to the file share.')
param mountPath string = '/mnt/azscripts/azscriptinput'

@description('Time in second before the container instance is suspended')
param sessionTime string = '1800'

param fileShareName string

param location string = resourceGroup().location

module storage '../storage/storageAccount.bicep' = {
  name: 'scriptStorage'
  params: {
    storageAccountName: storageName
    location: location
  }
}

resource scriptFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-08-01' = {
  name: '${storageName}/default/${fileShareName}'
  dependsOn: [
    storage
  ]
}

module secureContainerGroup 'scriptEnv.bicep' = {
  name: containerName
  dependsOn: [
    storage
  ]
  params: {
    fileShareName: scriptFileShare.name
    storageId: storage.outputs.provisionedResourceId
    storageName: storageName
    containerName: containerName
    location: location
    subnetIds: [
      subnetId
    ]
    toolVersion: toolVersion
    type: type
    sessionTime: sessionTime
    mountPath: mountPath
    identityId: identityId
  }
}

output containerGroupName string = containerName
