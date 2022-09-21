param nsgName string
param securityRules array = []
param location string = resourceGroup().location
param defaultWorkspaceId string = ''
param defaultDiagName string = 'Default'
param collectedLogs array = [
  {
    category: 'NetworkSecurityGroupEvent'
    enabled: true
  }
  {
    category: 'NetworkSecurityGroupRuleCounter'
    enabled: true
  }
]
param tags object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: securityRules
  }
}

resource defaultDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(defaultWorkspaceId)) {
  name: defaultDiagName
  scope: nsg
  properties: {
    logs: collectedLogs
    workspaceId: defaultWorkspaceId
  }
}

output nsgID string = nsg.id
