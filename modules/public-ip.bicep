param publicIpName string
param location string

resource pip 'Microsoft.Network/publicIPAddresses@2024-03-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

output publicIpId string = pip.id
