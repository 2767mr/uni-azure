@description('Location of the virtual network.')
param location string

@description('Name of the virtual network.')
param vnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'ingress-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'app-subnet'
        properties: {
          addressPrefix: '10.0.2.0/23'
        }
      }
    ]
  }
}

@description('Id of the ingress subnet.')
output ingressSubnetId string = vnet.properties.subnets[0].id

@description('Id of the container app environment subnet.')
output containerAppEnvSubnetId string = vnet.properties.subnets[1].id
