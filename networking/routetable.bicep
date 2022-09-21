param virtualHubName string
param routes array
param rtName string

resource virtualhub 'Microsoft.Network/virtualHubs@2021-05-01' existing = {
  name: virtualHubName
}

resource routetable 'Microsoft.Network/virtualHubs/hubRouteTables@2021-05-01' = {
  name: rtName
  parent: virtualhub
  properties: {
    routes: routes
  }
}

output routetableId string = routetable.id
