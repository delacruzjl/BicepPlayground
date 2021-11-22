param name string
param location string
param addressPrefix string
param subnets array

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    enableDdosProtection: false
    subnets: subnets
  }
}

output info object = {
  id: vnet.id
  subnets: vnet.properties.subnets
}
