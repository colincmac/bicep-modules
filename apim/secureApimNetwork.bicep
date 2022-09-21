@description('Region to deploy the resources.')
param location string = resourceGroup().location

@description('Existing virtual network name.')
param existingVnetName string

@description('Virtual network subnet name.')
param subnetName string = 'APIM'

@description('Virtual network subnet prefix.\n https://docs.microsoft.com/en-us/azure/api-management/virtual-network-concepts?tabs=stv2#subnet-size')
param subnetPrefix string = '10.0.4.0/27'

@description('Name of NSG to create for the APIM subnet.')
param apimNsgName string = 'apim-NSG'

@description('If `true`, the APIM instance is external and traffic over ports 80 & 443 are allowed.')
param isExternal bool = true

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: existingVnetName
}

var externalApimSecurityRules = [
  {
    name: 'Client_communication_to_API_Management'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefix: 'Internet'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
  {
    name: 'Secure_Client_communication_to_API_Management'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'Internet'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 110
      direction: 'Inbound'
    }
  }
]

var baseSecurityRules = [
  {
    name: 'Management_endpoint_for_Azure_portal_and_Powershell'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3443'
      sourceAddressPrefix: 'ApiManagement'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
  {
    name: 'Dependency_on_Redis_Cache'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '6381-6383'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 130
      direction: 'Inbound'
    }
  }
  {
    name: 'Dependency_to_sync_Rate_Limit_Inbound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '4290'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 135
      direction: 'Inbound'
    }
  }
  {
    name: 'Dependency_on_Azure_SQL'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '1433'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Sql'
      access: 'Allow'
      priority: 140
      direction: 'Outbound'
    }
  }
  {
    name: 'Dependency_for_Log_to_event_Hub_policy'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '5671'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'EventHub'
      access: 'Allow'
      priority: 150
      direction: 'Outbound'
    }
  }
  {
    name: 'Dependency_on_Redis_Cache_outbound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '6381-6383'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 160
      direction: 'Outbound'
    }
  }
  {
    name: 'Depenedency_To_sync_RateLimit_Outbound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '4290'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 165
      direction: 'Outbound'
    }
  }
  {
    name: 'Dependency_on_Azure_File_Share_for_GIT'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '445'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Storage'
      access: 'Allow'
      priority: 170
      direction: 'Outbound'
    }
  }
  {
    name: 'Azure_Infrastructure_Load_Balancer'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '6390'
      sourceAddressPrefix: 'AzureLoadBalancer'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 180
      direction: 'Inbound'
    }
  }
  {
    name: 'Publish_DiagnosticLogs_And_Metrics'
    properties: {
      description: 'APIM Logs and Metrics for consumption by admins and your IT team are all part of the management plane'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureMonitor'
      access: 'Allow'
      priority: 185
      direction: 'Outbound'
      destinationPortRanges: [
        '443'
        '12000'
        '1886'
      ]
    }
  }
  {
    name: 'Connect_To_SMTP_Relay_For_SendingEmails'
    properties: {
      description: 'APIM features the ability to generate email traffic as part of the data plane and the management plane'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Internet'
      access: 'Allow'
      priority: 190
      direction: 'Outbound'
      destinationPortRanges: [
        '25'
        '587'
        '25028'
      ]
    }
  }
  {
    name: 'Authenticate_To_Azure_Active_Directory'
    properties: {
      description: 'Connect to Azure Active Directory for Developer Portal Authentication or for Oauth2 flow during any Proxy Authentication'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureActiveDirectory'
      access: 'Allow'
      priority: 200
      direction: 'Outbound'
      destinationPortRanges: [
        '80'
        '443'
      ]
    }
  }
  {
    name: 'Dependency_on_Azure_Storage'
    properties: {
      description: 'APIM service dependency on Azure Blob and Azure Table Storage'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Storage'
      access: 'Allow'
      priority: 100
      direction: 'Outbound'
    }
  }
  {
    name: 'Publish_Monitoring_Logs'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureCloud'
      access: 'Allow'
      priority: 300
      direction: 'Outbound'
    }
  }
  {
    name: 'Access_KeyVault'
    properties: {
      description: 'Allow APIM service control plane access to KeyVault to refresh secrets'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureKeyVault'
      access: 'Allow'
      priority: 350
      direction: 'Outbound'
      destinationPortRanges: [
        '443'
      ]
    }
  }
  {
    name: 'Deny_All_Internet_Outbound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Internet'
      access: 'Deny'
      priority: 999
      direction: 'Outbound'
    }
  }
]

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: apimNsgName
  location: location
  properties: {
    securityRules: isExternal ? concat(externalApimSecurityRules, baseSecurityRules) : baseSecurityRules
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetPrefix
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

output subnetId string = subnet.id
