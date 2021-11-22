param name string
param location string
param pipId string
param subnetId string

// dependsOn pip
resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    dnsName: '${name}.bastion.azure.com'
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pipId
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}
