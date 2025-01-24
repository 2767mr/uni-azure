@description('Location of the ingress.')
param location string

/* ingress parameters */
@description('Name of the ingress.')
param ingressName string

@description('Port exposed to the internet.')
param frontendPort int
/**************************************************/

/* Dependencies */
@description('Id of the ingress subnet.')
param ingressSubnetId string

@description('Fully qualified domain name of the exposed applciation.')
param backendFQDN string
/**************************************************/


resource publicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'public-ip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: { name:'Standard', tier:'Regional' }
  zones: [
    '1','2', '3'
  ]
}

resource policy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2024-05-01' = {
  name: '${ingressName}-policy'
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

resource ingress 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: ingressName
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
        name: 'ingress-ip-config'
        properties: {
          subnet: {
            id: ingressSubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontend-ip-config'
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'frontend-port'
        properties: {
          port: frontendPort
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backend-pool'
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
        name: 'backend-http-settings'
        properties: {
          port: 443
          protocol: 'Https'
          hostName: backendFQDN
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', ingressName, 'frontend-probe')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'http-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', ingressName, 'frontend-ip-config')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', ingressName, 'frontend-port')
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
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', ingressName, 'http-listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', ingressName, 'backend-pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', ingressName, 'backend-http-settings')
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
