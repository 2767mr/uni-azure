param networkSecurityGroupName string
param location string
param frontendPort int
param backendPort int
param databasePort int
param internalSourceAddressPrefix string


resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowFrontend'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '${frontendPort}'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowBackend'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '${backendPort}'
          sourceAddressPrefix: '*'  // accesible from outside for testing
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowDatabase'
        properties: {
          priority: 300
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '${databasePort}'
          sourceAddressPrefix: internalSourceAddressPrefix
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
