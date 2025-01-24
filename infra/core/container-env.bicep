@description('Location of the container app environment.')
param location string

/* Container app environment parameters */
@description('Name of the container app environment.')
param containerAppEnvName string
/**************************************************/

/* Dependencies */
@description('Id of the container app envoironment subnet')
param containerAppEnvSubnetId string

@description('Customer id of the log analytics workspace.')
param logAnalyticsCustomerId string

@description('Primary shared key of the log analytics workspace.')
@secure()
param logAnalyticsSharedKey string

@description('Name of the storage account.')
param storageAccountName string

@description('Key of the storage account.')
@secure()
param storageAccountKey string
/**************************************************/


resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  location: location
  name: containerAppEnvName
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        sharedKey: logAnalyticsSharedKey
        customerId: logAnalyticsCustomerId
      }
    }
    vnetConfiguration: {
      internal: false
      infrastructureSubnetId: containerAppEnvSubnetId
    }
  }
}

resource storage 'Microsoft.App/managedEnvironments/storages@2024-03-01' = {
  name: 'database-storage'
  parent: containerAppEnv
  properties: {
    azureFile: {
      shareName: 'database'
      accountName: storageAccountName
      accountKey: storageAccountKey
      accessMode: 'ReadWrite'
    }
  }
}

@description('Id of the container app environment.')
output containerAppEnvId string = containerAppEnv.id
