param location string = resourceGroup().location
param accountName string

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

param privateEndpointConnName string = toLower('${accountName}')
param privateEndpointName string = '${accountName}-pvt-ep'
param privateEndpointSubnetId string
param privateDNSZoneId string

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2020-06-01-preview' = {
  name: accountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: any({
    createMode: 'Default'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    publicNetworkAccess: publicNetworkAccess
  })
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointConnName
        properties: {
          privateLinkServiceId: databaseAccount.id
          groupIds: [
            'Sql'
          ]
        }
      }
    ]
  }
}

resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: 'default'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: accountName
        properties: {
          privateDnsZoneId: privateDNSZoneId
        }
      }
    ]
  }
}
