@minLength(3)
@maxLength(24)
param storageAccountName string = 'stg${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param tags object = {}
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param skuName string = 'Standard_LRS'

@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param kind string = 'StorageV2'

@allowed([
  'Cool'
  'Hot'
])
param accessTier string = 'Hot'

param allowBlobPublicAccess bool = false

resource storageAccountResources 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: toLower(storageAccountName)
  location: location
  tags: tags
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: allowBlobPublicAccess
    accessTier: accessTier
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
  kind: kind
  sku: {
    name: skuName
  }
}

output provisionedResourceId string = storageAccountResources.id
output provisionedResourceName string = storageAccountResources.name
output provisionedResourceApiVersion string = storageAccountResources.apiVersion
output provisionedLocationName string = storageAccountResources.location
output primaryBlobEndpoint string = storageAccountResources.properties.primaryEndpoints.blob
