param publicIPName string
param location string

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: publicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: { name:'Standard', tier:'Regional' }
  zones: [
    '1','2', '3'
  ]
}

output publicIPId string = publicIP.id
