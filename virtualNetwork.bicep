param virtualNetworkName string
param location string
param addressSpacePrefix string
param appGatewaySubnetName string
param appGatewaySubnetAddressPrefix string
param appSubnetName string
param appSubnetAddressPrefix string


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
      {
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetAddressPrefix
        }
      }
    ]
  }
}

output appGatewaySubnetId string = vnet.properties.subnets[0].id
output appSubnetId string = vnet.properties.subnets[1].id
