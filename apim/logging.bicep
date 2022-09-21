param apimName string
param loggerName string = 'default'
param appInsightsId string
param appInsightsInstrumentationKey string

// TODO: Improve logging
// https://docs.microsoft.com/en-us/azure/api-management/observability#overview

resource apim 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apimName
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  parent: apim
  name: loggerName
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

resource apimDiag 'Microsoft.ApiManagement/service/diagnostics@2021-08-01' = {
  parent: apim
  name: 'applicationinsights'
  properties: {
    loggerId: apimLogger.id
    alwaysLog: 'allErrors'
    sampling: {
      percentage: 100
      samplingType: 'fixed'
    }
  }
}
