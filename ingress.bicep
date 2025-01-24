param ingressControllerName string
param location string

param ingressControllerSubnetId string
param publicIPId string

param backendFQDN string

resource policy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2024-05-01' = {
  name: '${ingressControllerName}policy'
  location: location
  properties: {
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType:'OWASP'
          ruleSetVersion: '3.2'
        }
      ]
    }
    policySettings: {
      mode: 'Detection'
      state: 'Enabled'
      fileUploadLimitInMb: 100
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
    }
  }
}

resource ingressController 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: ingressControllerName
  location: location
  zones: ['1', '2', '3']
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      family: 'Generation_1'
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
        name: 'frontendPort'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: backendFQDN
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: 'frontend-probe'
        properties: {
          protocol: 'Https'
          path: '/tiles/get_trips'
          pickHostNameFromBackendHttpSettings: true
          interval: 30
          timeout: 30
          unhealthyThreshold: 2
          port: 443
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backendHttpSettings'
        properties: {
          port: 443
          protocol: 'Https'
          hostName: backendFQDN
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', ingressControllerName, 'frontend-probe')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', ingressControllerName, 'ingressControllerFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', ingressControllerName, 'frontendPort')
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
          priority: 1
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', ingressControllerName, 'httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', ingressControllerName, 'backendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', ingressControllerName, 'backendHttpSettings')
          }
        }
      }
    ]
    enableHttp2: true
    firewallPolicy: {
      id: policy.id
    }
  }
}
