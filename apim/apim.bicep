//Parameters
@minLength(3)
@maxLength(24)
@description('Globally unique name of the API Management Service to provision')
param apimName string

@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string

@description('The name of the owner of the service')
@minLength(1)
param publisherName string

param location string = resourceGroup().location

@allowed([
  'Basic'
  'Consumption'
  'Developer'
  'Isolated'
  'Premium'
  'Standard'
])
@description('The pricing tier of this API Management service')
param skuSize string = 'Premium'

@description('The instance size of this API Management service.')
param capacitySize int = 1

@description('Id of VNET subnet to deploy APIM.')
param existingSubnetId string

@allowed([
  'None'
  'External'
  'Internal'
])
@description('''The type of VPN in which API Management service needs to be configured in.
**None** (Default Value if `existingSubnetId` is NOT defined) means the API Management service is not part of any Virtual Network.
**External** (Default Value if `existingSubnetId` is defined) means the API Management deployment is set up inside a Virtual Network having an Internet Facing Endpoint.
**Internal** means that API Management deployment is setup inside a Virtual Network having an Intranet Facing Endpoint only.''')
param vnetType string = empty(existingSubnetId) ? 'None' : 'External'

// param appInsightsName string
// param appInsightsId string
// param appInsightsInstrumentationKey string

// TODO: Allow User Assigned Managed Identities
// TODO: Enable AppInsights

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apimName
  location: location
  sku: {
    name: skuSize
    capacity: capacitySize
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkConfiguration: {
      subnetResourceId: existingSubnetId
    }
    virtualNetworkType: vnetType
  }
}

output provisionedResourceId string = apim.id
output provisionedResourceName string = apim.name
output provisionedLocationName string = apim.location
