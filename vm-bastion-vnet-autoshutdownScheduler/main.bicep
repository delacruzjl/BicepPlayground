targetScope = 'subscription'

param location string
param projectName string 
param environment string
param instance string
param vmUser string
@secure()
param vmPassword string

var resourceGroupName =  'rg-${projectName}-${environment}-${location}-${instance}'
var bastionHostName = 'bas-${projectName}-${environment}-${location}-${instance}'
var pipName = 'pip-${projectName}-${environment}-${location}-${instance}'
var vmName = 'vm-${projectName}-${environment}-${location}-${instance}'
var autoShutdownSchedule = 'shutdown-computevm-${vmName}'
var vnetName = 'vnet-${projectName}-${environment}-${location}-${instance}'
var subnets = [
  'Default' 
  'AzureBastionSubnet'
]
var vnetAddress = '10.0'

// resource group
module rg 'resource-group.bicep' = {
  name: 'ResourceGroup'
  params: {
    name: resourceGroupName
    location: location
  }
}

// vnet with 2 subnets
module vnet 'vnet.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'VNET'
  params: {
    location: location
    name: vnetName
    addressPrefix: '${vnetAddress}.0.0/16'
    subnets: [for (item, i) in subnets: {
        name: item
        properties: {
          addressPrefix: '${vnetAddress}.${i + 1}.0/26'
        }
      }]
  }
  dependsOn: [
    rg
  ]
}
// ------

module vm 'vm.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'VM'
  params: {
    name: vmName
    projectName: projectName
    environment: environment
    instance: instance
    location: location
    subnetId: vnet.outputs.info.subnets[0].id
    vmPassword: vmPassword
    vmUser: vmUser
    spotVM: true
    spotEvictionPolicy: 'Delete'
  }
  dependsOn: [
    rg
  ]
}

module scheduler 'vm-scheduler.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'Auto_Shutdown_2000hrs'
  params: {
    name: autoShutdownSchedule
    location: location
    vmId: vm.outputs.id
    dailyOcurrenceTime: '2000'
    notificationEmail: 'jose.delacruz@microsoft.com'
    enableNotification: false
  }
}


module pip 'pip.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'PIP'
  params: {
    location: location
    name: pipName
  }
  dependsOn: [
    rg
  ]
}

module bastion 'bastion.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'BastionHost'
  params: {
    name: bastionHostName
    location: location
    pipId: pip.outputs.id
    subnetId:  vnet.outputs.info.subnets[1].id
  }
}


