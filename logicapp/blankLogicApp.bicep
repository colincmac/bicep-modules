param location string = resourceGroup().location
param logicAppName string

var logicAppDef = loadJsonContent('blank-logic-app-definition.json')

// Example blank logic app definition
// var blankDef = {
//   '$schema': 'https://schema.management.azure.com/schemas/2016-06-01/Microsoft.Logic.json'
//   contentVersion: '1.0.0.0'
//   parameters: {}
//   triggers: {}
//   actions: {}
//   outputs: {}
// }

resource logicAppNew 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    definition: logicAppDef
  }
}

output resourceId string = logicAppNew.id
