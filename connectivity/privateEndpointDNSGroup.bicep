param privateEndpointName string
param privateDNSZoneId string
param dnsGroupName string = 'default'
param dnsZoneConfigName string = 'config1'

resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${privateEndpointName}/${dnsGroupName}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: dnsZoneConfigName
        properties: {
          privateDnsZoneId: privateDNSZoneId
        }
      }
    ]
  }
}
