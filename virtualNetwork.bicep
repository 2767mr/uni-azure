param virtualNetworkName string
param location string
param addressSpacePrefix string
param appGatewaySubnetName string
param appGatewaySubnetAddressPrefix string


resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [addressSpacePrefix]
    }
    subnets: [
      {
        name: appGatewaySubnetName
        properties: {
          addressPrefix: appGatewaySubnetAddressPrefix
        }
      }
    ]
  }
}

output appGatewaySubnetId string = vnet.properties.subnets[0].id
