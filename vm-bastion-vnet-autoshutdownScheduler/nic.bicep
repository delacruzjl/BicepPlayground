param name string
param location string
param subnetId string
param nsgId string

// dependsOn nsg
resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

output id string = nic.id
