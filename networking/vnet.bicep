param vnetAddressPrefixes array
param vnetName string
param subnets array
param location string = resourceGroup().location
param tags object = {}

param defaultWorkspaceId string = ''
param defaultDiagName string = 'Default'
param collectedMetrics array = [
  {
    category: 'AllMetrics'
    enabled: true
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: subnets
  }
}

resource defaultDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(defaultWorkspaceId)) {
  name: defaultDiagName
  scope: vnet
  properties: {
    metrics: collectedMetrics
    workspaceId: defaultWorkspaceId
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output vnetSubnets array = vnet.properties.subnets
