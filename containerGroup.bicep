param containerGroupName string
param location string
param logAnalyticsId string
param logAnalyticsKey string

param cpu int
param memoryGB int

param frontendContainerName string
param frontendContainerImage string
param frontendPort int

param backendContainerName string
param backendContainerImage string
param backendPort int

param databaseContainerName string
param databaseContainerImage string
param databasePort int


resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  properties: {
    containers: [
      {
        name: frontendContainerName
        properties: {
          image: frontendContainerImage
          ports: [
            {
              port: frontendPort
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpu
              memoryInGB: memoryGB
            }
          }
        }
      }
      {
        name: backendContainerName
        properties: {
          image: backendContainerImage
          ports: [
            {
              port: backendPort
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpu
              memoryInGB: memoryGB
            }
          }
        }
      }
      {
        name: databaseContainerName
        properties: {
          image: databaseContainerImage
          ports: [
            {
              port: databasePort
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpu
              memoryInGB: memoryGB
            }
          }
        }
      }
    ]
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: frontendPort
          protocol: 'TCP'
        }
      ]
    }
    diagnostics: {
      logAnalytics: {
        workspaceId: logAnalyticsId
        workspaceKey: logAnalyticsKey
      }
    }
  }
}
