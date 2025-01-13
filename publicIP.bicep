param publicIPName string
param location string

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: publicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

output publicIPId string = publicIP.id
