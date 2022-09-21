param storageName string
param containerName string
param identityId string = ''
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
param storageId string

param subnetIds array = []
param location string = resourceGroup().location

// Specifies which version to use if no specific toolVersion is provided (Azure CLI latest or Azure PowerShell latest)
var version = (type == 'AzureCLI' && toolVersion == '' ? 'latest' : type == 'AzurePowerShell' && toolVersion == '' ? 'az7.3' : 'az${toolVersion}')

var azcliImage = 'mcr.microsoft.com/azure-cli:${version}'
var azpwshImage = 'mcr.microsoft.com/azuredeploymentscripts-powershell:${version}'

var azpwshCommand = [
  '/bin/sh'
  '-c'
  'pwsh -c \'Start-Sleep -Seconds ${sessionTime}\''
]

var azcliCommand = [
  '/bin/bash'
  '-c'
  'echo hello; sleep ${sessionTime}'
]

var subnets = [for id in subnetIds: {
  id: id
  name: last(split(id, '/'))
}]
resource containerGroupName 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: containerName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: type == 'AzureCLI' ? azcliImage : type == 'AzurePowerShell' ? azpwshImage : ''
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 2
            }
          }
          ports: [
            {
              protocol: 'TCP'
              port: 80
            }
          ]
          volumeMounts: [
            {
              name: 'filesharevolume'
              mountPath: mountPath
            }
          ]
          command: type == 'AzureCLI' ? azcliCommand : type == 'AzurePowerShell' ? azpwshCommand : null
        }
      }
    ]
    osType: 'Linux'
    subnetIds: subnets
    volumes: [
      {
        name: 'filesharevolume'
        azureFile: {
          readOnly: false
          shareName: fileShareName
          storageAccountName: storageName
          storageAccountKey: listKeys(storageId, '2019-06-01').keys[0].value
        }
      }
    ]
  }
}
