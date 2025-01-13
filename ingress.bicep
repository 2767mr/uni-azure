param ingressControllerName string
param location string

param ingressControllerSubnetId string
param publicIPId string

param frontendPort int
param backendIP string

// this does not work, so disabled ingress controller for now
param frontendIPConfigurationId string = newGuid()
param frontendPortId string = newGuid()
param httpListenerId string = newGuid()
param backendAddressPoolId string = newGuid()
param backendHttpSettingsId string = newGuid()

resource ingressController 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: ingressControllerName
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'ingressControllerIpConfig'
        properties: {
          subnet: {
            id: ingressControllerSubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        id: frontendIPConfigurationId
        name: 'ingressControllerFrontendIp'
        properties: {
          publicIPAddress: {
            id: publicIPId
          }
        }
      }
    ]
    frontendPorts: [
      {
        id: frontendPortId
        name: 'frontendPort'
        properties: {
          port: frontendPort
        }
      }
    ]
    backendAddressPools: [
      {
        id: backendAddressPoolId
        name: 'backendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: backendIP
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        id: backendHttpSettingsId
        name: 'backendHttpSettings'
        properties: {
          port: frontendPort
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        id: httpListenerId
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            id: frontendIPConfigurationId
          }
          frontendPort: {
            id: frontendPortId
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: httpListenerId
          }
          backendAddressPool: {
            id: backendAddressPoolId
          }
          backendHttpSettings: {
            id: backendHttpSettingsId
          }
        }
      }
    ]
  }
}
