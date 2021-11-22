param name string
param location string

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: name
  location: location
}

output id string = nsg.id
