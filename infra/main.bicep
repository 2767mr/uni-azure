@description('Location of all resources.')
param location string = deployment().location

@description('Name of the deplyoed resource group.')
param resourceGroupName string = 'azure-project-deployment'

/* Module names */
@description('Name of the log analytics workspace.')
param logAnalyticsName string = 'log-analytics'

@description('Name of the virtual network of the app.')
param vnetName string = 'vnet'

@description('Name of the storage account.')
// needs to be unique -> so pass it through terminal
// e.g. azureuniquedbstorage1337
param storageAccountName string

@description('Name of the container app environment.')
param containerAppEnvName string = 'container-app-env'

@description('Name of the ui container app.')
param uiContainerName string = 'frontend'

@description('Name of the tile server container app.')
param tilesContainerName string = 'tiles'

@description('Name of the postgres database container app.')
param postgresContainerName string = 'database'

@description('Name of the network-security-group.')
param networkSecurityName string = 'network-security'

@description('Name of the ingress.')
param ingressName string = 'ingress'
/**************************************************/

/* Container app requests */
@description('CPU quota for the tile server container app.')
param cpu int = 1

@description('Memory quota for the tile server container app.')
param memory string = '2.0Gi'
/**************************************************/

/* Container images for cointainer apps */
@description('The container image to pull for the UI container app.')
param uiContainerImage string = 'ghcr.io/2767mr/demo-frontend'

@description('The container image to pull for the tile server container app.')
param tilesContainerImage string = 'ghcr.io/maplibre/martin'

@description('The container image to pull for the postgres container app.')
param postgresContainerImage string = 'ghcr.io/dominikmascherbauer/demo-db'
/**************************************************/

/* Exposed ports of container apps */
@description('Exposed port of the UI container app.')
param uiPort int = 80

@description('Exposed port of the tile server container app.')
param tilesPort int = 3000

@description('Exposed port of the postgres container app.')
param postgresPort int = 5432

@description('Port exposed to the internet through the ingress.')
param frontendPort int = 80
/**************************************************/


/* Database environemnt varaibles for container apps */
@description('Name of the postgres database user in the container app.')
// must be named 'postgres' to work out with the database initialization
param postgresUser string = 'postgres'

@description('Password of the postgres database user in the container app.')
@secure()
param postgresPassword string = newGuid()

@description('Name of the postgres database in the container app.')
// must be named 'db' to work out with the database initialization
param postgresDatabase string = 'db'

@description('Connection URL for connecting to the databse.')
param databaseConnectionURL string = 'postgres://${postgresUser}:${postgresPassword}@${postgresContainerName}:${postgresPort}/${postgresDatabase}'
/**************************************************/


targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: resourceGroupName
  location: location
}

module logAnalytics './logging/log-analytics.bicep' = {
  scope: resourceGroup
  name: logAnalyticsName
  params: {
    logAnalyticsName: logAnalyticsName
    location: resourceGroup.location
  }
}

module vnet './core/vnet.bicep' = {
  scope: resourceGroup
  name: vnetName
  params: {
    location: location
    vnetName: vnetName
  }
}

module storageAccount './core/storage-account.bicep' = {
  scope: resourceGroup
  name: storageAccountName
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

module containerAppEnv './core/container-env.bicep' = {
  scope: resourceGroup
  name: containerAppEnvName
  params: {
    location: location
    containerAppEnvName: containerAppEnvName
    // implicit dependence on virtual network
    containerAppEnvSubnetId: vnet.outputs.containerAppEnvSubnetId
    // implicit dependence on log analytics workspace
    logAnalyticsCustomerId: logAnalytics.outputs.logAnalyticsCustomerId
    logAnalyticsSharedKey: logAnalytics.outputs.logAnalyticsSharedKey
    // implicit dependence on storage account module
    storageAccountName: storageAccount.name
    storageAccountKey: storageAccount.outputs.storageAccountKey
  }
}

module uiContainerApp './apps/ui.bicep' = {
  scope: resourceGroup
  name: uiContainerName
  params: {
    location: location
    // implicit dependence on container app environemnt
    containerAppEnvId: containerAppEnv.outputs.containerAppEnvId
    uiContainerName: uiContainerName
    uiContainerImage: uiContainerImage
    uiPort: uiPort
    cpu: cpu
    memory: memory
  }
}

module tilesContainerApp './apps/tiles.bicep' = {
  scope: resourceGroup
  name: tilesContainerName
  params: {
    location: location
    // implicit dependence on container app environemnt
    containerAppEnvId: containerAppEnv.outputs.containerAppEnvId
    tilesContainerName: tilesContainerName
    tilesContainerImage: tilesContainerImage
    tilesPort: tilesPort
    cpu: cpu
    memory: memory
    databaseConnectionURL: databaseConnectionURL
  }
}

module postgresContainerApp './apps/postgres.bicep' = {
  scope: resourceGroup
  name: postgresContainerName
  params: {
    location: location
    // implicit dependence on container app environemnt
    containerAppEnvId: containerAppEnv.outputs.containerAppEnvId
    postgresContainerName: postgresContainerName
    postgresContainerImage: postgresContainerImage
    postgresPort: postgresPort
    postgresUser: postgresUser
    postgresPassword: postgresPassword
    postgresDatabase: postgresDatabase
    cpu: cpu
    memory: memory
  }
}

module networkSecurity './core/network-security.bicep' = {
  scope: resourceGroup
  name: networkSecurityName
  params: {
    location: location
    networkSecurityName: networkSecurityName
    uiPort: uiPort
    tilesPort: tilesPort
    postgresPort: postgresPort
  }
}

module ingressController './core/ingress.bicep' = {
  scope: resourceGroup
  name: ingressName
  params: {
    location: location
    ingressName: ingressName
    // implicit dependence on vnet
    ingressSubnetId: vnet.outputs.ingressSubnetId
    frontendPort: frontendPort
    // implicit dependence on ui container app
    backendFQDN: uiContainerApp.outputs.uiFQDN
  }
}
