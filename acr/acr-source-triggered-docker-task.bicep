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
@description('The Docker file path relative to the source context.')
param dockerfilePath string = 'Dockerfile'

@description('The fully qualified image names including the repository and tag.')
param imageNames array

@description('The value of this property indicates whether the image built should be pushed to the registry or not.')
param isPushEnabled bool = true

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
      contextPath: contextPath //'https://github.com/gituser/acr-build-helloworld-node#main'
      type: 'Docker'
      dockerFilePath: dockerfilePath
      imageNames: imageNames
      isPushEnabled: isPushEnabled
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
