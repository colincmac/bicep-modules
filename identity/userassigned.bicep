param identityName string
param location string = resourceGroup().location
param tags object = {}

resource azidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
  tags: tags
}

output identityid string = azidentity.id
output clientId string = azidentity.properties.clientId
output principalId string = azidentity.properties.principalId
