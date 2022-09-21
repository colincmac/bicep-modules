param virtualHubName string
param vnetName string
param vnetId string
param associatedRouteTableId string
param propagatedRouteTableIds array

var propogatedRouteTables = [for id in propagatedRouteTableIds: {
  id: id
}]
resource virtual_hub 'Microsoft.Network/virtualHubs@2021-05-01' existing = {
  name: virtualHubName
}

resource vnet_vwanhub_connection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2021-05-01' = {
  name: '${vnetName}_connection'
  parent: virtual_hub
  properties: {
    remoteVirtualNetwork: {
      id: vnetId
    }
    routingConfiguration: {
      associatedRouteTable: {
        id: associatedRouteTableId
      }
      propagatedRouteTables: {
        ids: propogatedRouteTables
      }
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
}

output connectionId string = vnet_vwanhub_connection.id
