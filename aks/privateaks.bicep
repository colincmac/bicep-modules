param clusterName string
param logworkspaceid string
param privateDNSZoneId string
param aadGroupdIds array
param subnetId string
param identity object

@description('Specifies the number of agents (VMs) to host docker containers. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
param nodePoolCount int = 1

@allowed([
  'Linux'
  'Windows'
])
@description('Specifies the OS type for the vms in the node pool. Choose from Linux and Windows. Default to Linux.')
param nodePoolOsType string = 'Linux'

@description('Specifies the maximum number of pods that can run on a node. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
param nodePoolMaxPods int = 100

@description('Specifies the maximum number of nodes for auto-scaling for the node pool.')
param nodePoolMaxCount int = 2

@description('Specifies the minimum number of nodes for auto-scaling for the node pool.')
param nodePoolMinCount int = 1

@description('Specifies whether to enable auto-scaling for the node pool.')
param nodePoolEnableAutoScaling bool = true

@allowed([
  'Spot'
  'Regular'
])
@description('Specifies the virtual machine scale set priority: Spot or Regular.')
param nodePoolScaleSetPriority string = 'Regular'

@description('Specifies the Agent pool node labels to be persisted across all nodes in agent pool.')
param nodePoolNodeLabels object = {}

@description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule. - string')
param nodePoolNodeTaints array = []

param deployRegion string

@description('Resource Group name for deployed AKS resources')
param nodeResourceGroupName string = 'MC_${resourceGroup().name}_${clusterName}_${deployRegion}'

param kubernetesVersion string = '1.23.3'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  name: clusterName
  location: deployRegion
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: identity
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    nodeResourceGroup: nodeResourceGroupName
    podIdentityProfile: {
      enabled: true
    }
    dnsPrefix: clusterName
    agentPoolProfiles: [
      {
        name: 'burst01'
        mode: 'System'
        count: 1
        vmSize: 'Standard_B4ms'
        osDiskSizeGB: 0
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
        maxCount: nodePoolMaxCount
        minCount: nodePoolMinCount
        scaleSetPriority: nodePoolScaleSetPriority
        enableAutoScaling: nodePoolEnableAutoScaling
        nodeLabels: nodePoolNodeLabels
        nodeTaints: nodePoolNodeTaints
        maxPods: nodePoolMaxPods
        osType: 'Linux'
      }
      {
        name: 'burst02'
        mode: 'User'
        count: nodePoolCount
        vmSize: 'Standard_B4ms'
        osDiskSizeGB: 0
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
        maxCount: nodePoolMaxCount
        minCount: nodePoolMinCount
        scaleSetPriority: nodePoolScaleSetPriority
        enableAutoScaling: nodePoolEnableAutoScaling
        nodeLabels: nodePoolNodeLabels
        nodeTaints: nodePoolNodeTaints
        osType: nodePoolOsType
        maxPods: nodePoolMaxPods
      }
      {
        name: 'burst03'
        mode: 'User'
        count: nodePoolCount
        vmSize: 'Standard_B4ms'
        osDiskSizeGB: 0
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
        maxCount: nodePoolMaxCount
        minCount: nodePoolMinCount
        scaleSetPriority: nodePoolScaleSetPriority
        enableAutoScaling: nodePoolEnableAutoScaling
        nodeLabels: nodePoolNodeLabels
        nodeTaints: nodePoolNodeTaints
        osType: nodePoolOsType
        maxPods: nodePoolMaxPods
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      dockerBridgeCidr: '172.17.0.1/16'
      dnsServiceIP: '192.168.100.10'
      serviceCidr: '192.168.100.0/24'
      networkPolicy: 'azure'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
      privateDNSZone: privateDNSZoneId
    }
    enableRBAC: true
    aadProfile: {
      adminGroupObjectIDs: aadGroupdIds
      enableAzureRBAC: true
      managed: true
      tenantID: subscription().tenantId
    }
    addonProfiles: {
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: logworkspaceid
        }
        enabled: true
      }
      azurepolicy: {
        enabled: true
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
      }
      openServiceMesh: {
        enabled: true
        config: {} // this is configured post deployment, with gitops. 
      }
    }
  }
}

output kubeletIdentity string = aksCluster.properties.identityProfile.kubeletidentity.objectId
output keyvaultaddonIdentity string = aksCluster.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.objectId
output nodeRgName string = nodeResourceGroupName
