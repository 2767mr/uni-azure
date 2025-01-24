@description('Location of the network security group.')
param location string

@description('Name of the network security group.')
param networkSecurityName string

@description('Exposed port of the UI container app.')
param uiPort int

@description('Exposed port of the tile server container app.')
param tilesPort int

@description('Exposed port of the postgres container app.')
param postgresPort int


resource networkSecurity 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: networkSecurityName
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-ui'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '${uiPort}'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'allow-tiles'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '${tilesPort}'
          sourceAddressPrefix: '*' 
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'allow-postgres'
        properties: {
          priority: 300
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '${postgresPort}'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
