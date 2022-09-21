param plsName string
param appInsightsId string
param appInsightsName string

resource privateLinkScope 'microsoft.insights/privateLinkScopes@2021-07-01-preview' existing = {
  name: plsName
}

resource plsInsights 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: 'scoped-${appInsightsName}'
  parent: privateLinkScope
  properties: {
    linkedResourceId: appInsightsId
  }
}
