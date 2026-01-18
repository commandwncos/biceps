targetScope = 'subscription'

var default = loadYamlContent('default.yaml')

// ============================
// PARAMETERS
// ============================
param prefix string = 'rg'
param location string = 'eastus2'
param sshPublicKey string
param adminUsername string = 'azureuseradminfoo'

// ============================
// VARIABLES
// ============================
var rgName = toUpper('${prefix}-${guid(subscription().id)}')

// ============================
// RESOURCE GROUP
// ============================
resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgName
  location: location
  tags: default.tags
}



// ============================
// VNET + SUBNET (NSG NA SUBNET)
// ============================
module vnet './modules/vnet.bicep' = {
  name: 'deploy-vnet'
  scope: rg
  params: {
    vnetName: 'vnet-main'
    location: location
  }
}

// ============================
// PUBLIC IP
// ============================
module pip './modules/public-ip.bicep' = {
  name: 'deploy-pip'
  scope: rg
  params: {
    publicIpName: 'pip-vm01'
    location: location
  }
}

// ============================
// NIC
// ============================
module nic './modules/vnic.bicep' = {
  name: 'deploy-nic'
  scope: rg
  params: {
    nicName: 'nic-vm01'
    subnetId: vnet.outputs.subnetId
    publicIpId: pip.outputs.publicIpId
    location: location
  }
}

// ============================
// DATA DISK
// ============================
module dataDisk './modules/disk.bicep' = {
  name: 'deploy-disk'
  scope: rg
  params: {
    diskName: 'disk-vm01'
    location: location
    diskSizeGB: 64
  }
}

// ============================
// VIRTUAL MACHINE
// ============================
module vm './modules/vm.bicep' = {
  name: 'deploy-vm'
  scope: rg
  params: {
    vmName: 'vm01'
    location: location
    nicId: nic.outputs.nicId
    dataDiskId: dataDisk.outputs.diskId
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
  }
}
