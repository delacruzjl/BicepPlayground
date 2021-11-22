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

// resource group
module rg 'resource-group.bicep' = {
  name: 'resourceGroupDeploy'
  params: {
    name: resourceGroupName
    location: location
  }
}

// vnet with 2 subnets
module vnet 'vnet.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'DeployVNET'
  params: {
    location: location
    name: vnetName
    addressPrefix: '10.0.0.0/16'
    subnets: [for (item, i) in subnets: {
        name: item
        properties: {
          addressPrefix: '10.0.${i + 1}.0/26'
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
  name: 'VMDeploy'
  params: {
    name: vmName
    projectName: projectName
    environment: environment
    instance: instance
    location: location
    subnetId: vnet.outputs.info.subnets[0].id
    vmPassword: vmPassword
    vmUser: vmUser
  }
  dependsOn: [
    rg
  ]
}

module scheduler 'vm-scheduler.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'DeployAutoShutdown'
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
  name: 'DeployPIP'
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
  name: 'DeployBastionHost'
  params: {
    name: bastionHostName
    location: location
    pipId: pip.outputs.id
    subnetId:  vnet.outputs.info.subnets[1].id
  }
}


