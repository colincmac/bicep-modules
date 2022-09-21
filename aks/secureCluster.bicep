param clusterName string
param logworkspaceid string
param privateDNSZoneId string
param aadGroupdIds array
param identity object

param deployRegion string

@description('Resource Group name for deployed AKS resources')
param nodeResourceGroupName string = 'MC_${resourceGroup().name}_${clusterName}_${deployRegion}'

param kubernetesVersion string = '1.24.0'

param agentProfiles array

param clusterTags object = {}

param assignedPodIdentityProfiles array = []

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-01-02-preview' = {
  name: clusterName
  location: deployRegion
  tags: clusterTags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: identity
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    nodeResourceGroup: nodeResourceGroupName
    podIdentityProfile: {
      enabled: true
      userAssignedIdentities: assignedPodIdentityProfiles
      userAssignedIdentityExceptions: [
        {
          name: 'pod-identity-exception-flux'
          namespace: 'flux-system'
          podLabels: {
            'app.kubernetes.io/name': 'flux-extension'
          }
        }
      ]
    }
    dnsPrefix: clusterName
    agentPoolProfiles: agentProfiles
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
      azurepolicy: {
        enabled: true
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
        }
      }
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: logworkspaceid
        }
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
