param location string = resourceGroup().location
@minLength(5)
@maxLength(50)
param taskName string
param registryName string
param tags object = {}
param sourceName string = 'default'
param sourceBranch string = 'main'
param soureRepoUrl string // https://github.com/gituser/acr-build-helloworld-node#branch
param soureControlType string = 'Github'
param contextPath string // https://github.com/gituser/acr-build-helloworld-node#branch:folder
param agentPoolName string = 'default-pool'

@description('Base64 encoded value of the template/definition file content.')
param base64TaskContent string

@description('Base64 encoded value of the parameters/values file content.')
param base64Values string = ''

param sourceTriggerEvents array = [
  'commit'
]

@secure()
param githubPAT string

param identity object = {
  type: 'SystemAssigned'
}

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: registryName
}

resource task 'Microsoft.ContainerRegistry/registries/tasks@2019-06-01-preview' = {
  name: taskName
  parent: acr
  tags: tags
  location: location
  identity: identity
  properties: {
    platform: {
      architecture: 'amd64'
      os: 'Linux'
    }
    agentPoolName: agentPoolName
    step: {
      contextAccessToken: githubPAT
      contextPath: contextPath
      type: 'EncodedTask'
      encodedTaskContent: base64TaskContent
      encodedValuesContent: base64Values
    }
    trigger: {
      baseImageTrigger: {
        baseImageTriggerType: 'Runtime'
        name: 'default-image-trigger'
        status: 'Enabled'
      }
      sourceTriggers: [
        {
          name: sourceName
          sourceRepository: {
            branch: sourceBranch
            repositoryUrl: soureRepoUrl
            sourceControlType: soureControlType
            sourceControlAuthProperties: {
              tokenType: 'PAT'
              token: githubPAT
            }
          }
          sourceTriggerEvents: sourceTriggerEvents
        }
      ]
    }
  }
}
