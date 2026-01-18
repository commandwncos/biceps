param vnetName string
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet1'
        properties: {
          addressPrefix: '10.1.0.0/24'
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
