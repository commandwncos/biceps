targetScope = 'resourceGroup'
param nicName string
param location string
param subnetId string
param publicIpId string

resource nic 'Microsoft.Network/networkInterfaces@2024-03-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]
    
  }
}

output nicId string = nic.id
