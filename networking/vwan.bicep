param location string = resourceGroup().location

@maxLength(80)
param vwanName string

@allowed([
  'Standard'
  'Basic'
])
@description('Specifies the type of Virtual WAN.')
param vwanType string = 'Standard'

param virtualHubName string
param virtualHubAddressPrefix string = '192.168.0.0/24'

resource vwan 'Microsoft.Network/virtualWans@2021-05-01' = {
  name: vwanName
  location: location
  properties: {
    allowVnetToVnetTraffic: true
    allowBranchToBranchTraffic: true
    type: vwanType
  }
}

resource virtual_hub 'Microsoft.Network/virtualHubs@2021-05-01' = {
  name: virtualHubName
  location: location
  properties: {
    addressPrefix: virtualHubAddressPrefix
    virtualWan: {
      id: vwan.id
    }
  }
}

// resource rt_shared 'Microsoft.Network/virtualHubs/hubRouteTables@2020-05-01' = {
//   name: '${virtualHubName}/RT_SHARED'
//   properties: {
//     routes: [
//       {
//         name: 'route_to_shared_services'
//         destinationType: 'CIDR'
//         destinations: [
//           vnetSharedServicesAddressPrefix
//         ]
//         nextHopType: 'ResourceId'
//         nextHop: '${virtual_hub.id}/hubVirtualNetworkConnections/${vnetSharedServicesName}_connection'
//       }
//     ]
//   }
// }

// resource vnet_shared_services 'Microsoft.Network/virtualNetworks@2020-05-01' = {
//   name: vnet_shared_services_cfg.name
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         vnet_shared_services_cfg.addressSpacePrefix
//       ]
//     }
//     subnets: [
//       {
//         name: vnet_shared_services_cfg.subnetName
//         properties: {
//           addressPrefix: vnet_shared_services_cfg.subnetPrefix
//           networkSecurityGroup: {
//             properties: {
//               securityRules: [
//                 {
//                   properties: {
//                     direction: 'Inbound'
//                     protocol: '*'
//                     access: 'Allow'
//                   }
//                 }
//                 {
//                   properties: {
//                     direction: 'Outbound'
//                     protocol: '*'
//                     access: 'Allow'
//                   }
//                 }
//               ]
//             }
//           }
//         }
//       }
//     ]
//   }
// }

// resource vnet_isolated_1 'Microsoft.Network/virtualNetworks@2020-05-01' = {
//   name: vnet_isolated_1_cfg.name
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         vnet_isolated_1_cfg.addressSpacePrefix
//       ]
//     }
//     subnets: [
//       {
//         name: vnet_isolated_1_cfg.subnetName
//         properties: {
//           addressPrefix: vnet_isolated_1_cfg.subnetPrefix
//           networkSecurityGroup: {
//             properties: {
//               securityRules: [
//                 {
//                   properties: {
//                     direction: 'Inbound'
//                     protocol: '*'
//                     access: 'Allow'
//                   }
//                 }
//                 {
//                   properties: {
//                     direction: 'Outbound'
//                     protocol: '*'
//                     access: 'Allow'
//                   }
//                 }
//               ]
//             }
//           }
//         }
//       }
//     ]
//   }
// }

// resource vnet_isolated_2 'Microsoft.Network/virtualNetworks@2020-05-01' = {
//   name: vnet_isolated_2_cfg.name
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         vnet_isolated_2_cfg.addressSpacePrefix
//       ]
//     }
//     subnets: [
//       {
//         name: vnet_isolated_2_cfg.subnetName
//         properties: {
//           addressPrefix: vnet_isolated_2_cfg.subnetPrefix
//           networkSecurityGroup: {
//             properties: {
//               securityRules: [
//                 {
//                   properties: {
//                     direction: 'Inbound'
//                     protocol: '*'
//                     access: 'Allow'
//                   }
//                 }
//                 {
//                   properties: {
//                     direction: 'Outbound'
//                     protocol: '*'
//                     access: 'Allow'
//                   }
//                 }
//               ]
//             }
//           }
//         }
//       }
//     ]
//   }
// }

// resource vnet_shared_services_connection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-05-01' = {
//   name: '${virtual_hub_cfg.name}/${vnet_shared_services_cfg.name}_connection'
//   properties: {
//     remoteVirtualNetwork: {
//       id: vnet_shared_services.id
//     }
//     routingConfiguration: {
//       associatedRouteTable: {
//         id: '${virtual_hub.id}/hubRouteTables/defaultRouteTable'
//       }
//       propagatedRouteTables: {
//         ids: [
//           {
//             id: '${virtual_hub.id}/hubRouteTables/defaultRouteTable'
//           }
//           {
//             id: rt_shared.id
//           }
//         ]
//       }
//     }
//     allowHubToRemoteVnetTransit: true
//     allowRemoteVnetToUseHubVnetGateways: true
//     enableInternetSecurity: true
//   }
// }

// resource vnet_isolated_1_connection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-05-01' = {
//   name: '${virtual_hub_cfg.name}/${vnet_isolated_1_cfg.name}_connection'
//   properties: {
//     remoteVirtualNetwork: {
//       id: vnet_isolated_1.id
//     }
//     routingConfiguration: {
//       associatedRouteTable: {
//         id: rt_shared.id
//       }
//       propagatedRouteTables: {
//         ids: [
//           {
//             id: '${virtual_hub.id}/hubRouteTables/defaultRouteTable'
//           }
//         ]
//       }
//     }
//     allowHubToRemoteVnetTransit: true
//     allowRemoteVnetToUseHubVnetGateways: true
//     enableInternetSecurity: true
//   }
//   dependsOn: [
//     vnet_shared_services_connection
//   ]
// }

// resource vnet_isolated_2_connection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-05-01' = {
//   name: '${virtual_hub_cfg.name}/${vnet_isolated_2_cfg.name}_connection'
//   properties: {
//     remoteVirtualNetwork: {
//       id: vnet_isolated_2.id
//     }
//     routingConfiguration: {
//       associatedRouteTable: {
//         id: rt_shared.id
//       }
//       propagatedRouteTables: {
//         ids: [
//           {
//             id: '${virtual_hub.id}/hubRouteTables/defaultRouteTable'
//           }
//         ]
//       }
//     }
//     allowHubToRemoteVnetTransit: true
//     allowRemoteVnetToUseHubVnetGateways: true
//     enableInternetSecurity: true
//   }
//   dependsOn: [
//     vnet_isolated_1_connection
//   ]
// }

output vhubId string = virtual_hub.id
