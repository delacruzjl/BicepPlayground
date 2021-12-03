param name string
param subnetId string
param pipId string
param root_cert string

resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: name
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: name
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: pipId
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: true
    vpnClientConfiguration: {
      vpnAuthenticationTypes: [
        'Certificate'
      ]
      vpnClientAddressPool: {
        addressPrefixes: [
          '172.16.201.0/24'
        ]
      }
      vpnClientProtocols: [
        'IkeV2'
        'OpenVPN'
      ]
      vpnClientRootCertificates: [
        {
          name: 'SurfaceBook2019_Root'
          properties: {
            publicCertData: root_cert
          }
        }
      ]
    }
  }
}
