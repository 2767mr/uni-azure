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

param postgresUser string
@secure()
param postgresPassword string
param postgresDatabase string
param postgresHost string
param postgresPort int

param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName 
  location: location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
}

resource storageAccountFS 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {}
}

resource storageAccountFSShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  name: 'database'
  parent: storageAccountFS
  properties: {

  }
}

resource menv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  location: location
  name: 'menv'
  properties: {

  }
}

resource storage 'Microsoft.App/managedEnvironments/storages@2024-03-01' = {
  name: 'asdfstorage'
  parent: menv
  dependsOn: [
    storageAccountFSShare
  ]
  properties: {
    azureFile: {
      shareName: 'database'
      accountName: storageAccount.name
      accountKey: storageAccount.listKeys().keys[0].value
      accessMode: 'ReadWrite'
    }
  }
}

// Frontend Container App
resource frontendContainerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: frontendContainerName
  location: location
  properties: {
    environmentId: menv.id
    configuration: {
      ingress: {
        external: true
        targetPort: frontendPort
      }
    }
    template: {
      containers: [
        {
          name: frontendContainerName
          image: frontendContainerImage
          resources: {
            cpu: cpu
            memory: '2.0Gi'
          }
        }
      ]
    }
  }
}

// Backend Container App
resource backendContainerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: backendContainerName
  location: location
  properties: {
    environmentId: menv.id
    configuration: {
      ingress: {
        external: true
        targetPort: backendPort
      }
    }
    template: {
      containers: [
        {
          name: backendContainerName
          image: backendContainerImage
          resources: {
            cpu: cpu
            memory: '2.0Gi'
          }
          env: [
            {
              name: 'DATABASE_URL'
              value: 'postgres://${postgresUser}:${postgresPassword}@${postgresHost}:${postgresPort}/${postgresDatabase}'
            }
          ]
        }
      ]
    }
  }
}

// Database Container App
resource databaseContainerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: databaseContainerName
  location: location
  dependsOn: [
    storage
  ]
  properties: {
    environmentId: menv.id
    configuration: {
      ingress: {
        external: true
        targetPort: databasePort
      }
    }
    template: {
      containers: [
        {
          name: databaseContainerName
          image: databaseContainerImage
          resources: {
            cpu: cpu
            memory: '2.0Gi'
          }
          env: [
            {
              name: 'POSTGRES_USER'
              value: postgresUser
            }
            {
              name: 'POSTGRES_PASSWORD'
              value: postgresPassword
            }
            {
              name: 'POSTGRES_DB'
              value: postgresDatabase
            }
          ]
          volumeMounts: [
            {
              volumeName: 'database-volume'
              mountPath: '/var/lib/postgresql/data'
            }
          ]
        }
      ]
      volumes: [
        {
          name: 'database-volume'
          storageName: 'asdfstorage'
          storageType: 'AzureFile'
        }
      ]
    }
  }
}
