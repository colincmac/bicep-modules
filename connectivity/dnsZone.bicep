@description('The name of the DNS zone to be created. Must have at least 2 segements, e.g. hostname.org')
param dnsZoneName string
param commonTags object = {}

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: dnsZoneName
  location: 'global'
  tags: commonTags
  properties: {
    zoneType: 'Public'
  }
}
