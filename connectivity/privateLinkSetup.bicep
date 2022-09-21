param privateEndpointName string
param privateDNSZoneName string
param resourceId string
param peSubnetName string
param vnetName string

param vnetResourceGroupName string = resourceGroup().name
param location string = resourceGroup().location

@description('The ID(s) of the group(s) obtained from the remote resource that this private endpoint should connect to.')
param groupIds array

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
}

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: vnet
  name: peSubnetName
}

module privateEndpoint './privateendpoint.bicep' = {
  name: 'privateEndpoint'
  params: {
    groupIds: groupIds
    privateEndpointName: privateEndpointName
    privatelinkConnName: '${privateEndpointName}-conn'
    resourceId: resourceId
    subnetid: peSubnet.id
    location: location
  }
}

module privateDNSZone './privatednszone.bicep' = {
  name: privateDNSZoneName
  params: {
    privateDNSZoneName: privateDNSZoneName
  }
}

module privateDNSLink './privatednslink.bicep' = {
  name: 'privateDNSLink'
  params: {
    privateDnsZoneName: privateDNSZone.outputs.privateDNSZoneName
    vnetId: vnet.id
  }
}

module privateEndpointKVDNSSetting './privateEndpointDNSGroup.bicep' = {
  scope: resourceGroup()
  name: 'dnsSetting'
  params: {
    privateDNSZoneId: privateDNSZone.outputs.privateDNSZoneId
    privateEndpointName: privateEndpoint.outputs.privateEndpointName
  }
}
