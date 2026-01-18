targetScope = 'resourceGroup'
param diskName string
param location string
param diskSizeGB int

resource disk 'Microsoft.Compute/disks@2024-03-02' = {
  name: diskName
  location: location
  
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    diskSizeGB: diskSizeGB
    creationData: {
      createOption: 'Empty'
    }
  }
}

output diskId string = disk.id
