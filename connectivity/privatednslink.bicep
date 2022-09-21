param privateDnsZoneName string
param vnetId string
param linkSuffix string = 'link'
param tags object = {}

resource hubLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDnsZoneName}/${privateDnsZoneName}-${linkSuffix}'
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}
