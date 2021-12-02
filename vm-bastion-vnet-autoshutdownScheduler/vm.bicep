param name string
param location string
param projectName string
param environment string
param instance string
param vmUser string
param vmPassword string
param subnetId string
param spotVM bool = true
@allowed([
  'Standard_B2ms'
  'Standard_DS3_v2'
])
param vmSize string
@allowed([
  'Delete'
  'Deallocate'
])
param spotEvictionPolicy string = 'Delete'
@allowed([
  '20h1-pro-g2'
  '19h1-ent'
])
param skuImage string

var nicName = 'nic-${projectName}-${environment}-${location}-${instance}'
var nsgName = 'nsg-${projectName}-${environment}-${location}-${instance}'
var osdiskName = 'osdisk${projectName}${environment}${location}${instance}'
var computerName = 'vm-${projectName}-de'

resource vm 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: name
  location: location
  properties: {
    priority: spotVM ? 'Spot' : 'Regular'
    evictionPolicy: spotVM ? spotEvictionPolicy : null
    billingProfile: spotVM ? {
      maxPrice: 30
    } : null
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: skuImage
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: osdiskName
        createOption: 'FromImage'
        caching: 'ReadWrite'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: computerName
      adminUsername: vmUser
      adminPassword: vmPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.outputs.id
        }
      ]
    }
    licenseType: 'Windows_Client'
  }
}

module nic 'nic.bicep' = {
  name: 'DeployNIC'
  params: {
    location: location
    name: nicName
    nsgId: nsg.outputs.id
    subnetId: subnetId
  }
}

module nsg 'nsg.bicep' = {
  name: 'DeployNSG'
  params: {
    location: location
    name: nsgName
  }
}

output id string = vm.id
