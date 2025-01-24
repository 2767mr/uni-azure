param resourceGroupName string = 'azure-project-deployment'
param location string = deployment().location

param logAnalyticsName string = 'log-analytics'

param containerGroupName string = 'services'
param cpu int = 1
// param memoryGB int = 2

param frontendContainerName string = 'frontend'
param frontendContainerImage string = 'ghcr.io/2767mr/demo-frontend'
param frontendPort int = 80

param backendContainerName string = 'tiles'
param backendContainerImage string = 'ghcr.io/maplibre/martin'
param backendPort int = 3000

param databaseContainerName string = 'database'
param databaseContainerImage string = 'ghcr.io/dominikmascherbauer/demo-db'
param databasePort int = 5432

param postgresUser string = 'postgres'
@secure()
param postgresPassword string = newGuid()
param postgresDatabase string = 'db'
param postgresHost string = databaseContainerName
param postgresPort int = 5432

param storageAccountName string = 'azureuniquedbstorage1337'

param networkSecurityGroupName string = 'network-security'
param internalSourceAddressPrefix string = '10.0.0.0/23'

param virtualNetworkName string = 'virtual-network'
param addressSpacePrefix string = '10.0.0.0/16'
param appGatewaySubnetName string = 'app-gateway-subnet'
param appGatewaySubnetAddressPrefix string = '10.0.2.0/23'

param publicIPName string = 'public-ip'

// param ingressControllerName string = 'ingress-controller'
// param backendIP string = '10.0.0.4' // Replace with your backend container IP

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: resourceGroupName
  location: location
}

module logAnalytics './logAnalytics.bicep' = {
  scope: resourceGroup
  name: logAnalyticsName
  params: {
    logAnalyticsName: logAnalyticsName
    location: resourceGroup.location
  }
}

module containerGroup './containerGroup.bicep' = {
  scope: resourceGroup
  name: containerGroupName
  params: {
    location: location
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    logAnalyticsKey : logAnalytics.outputs.logAnalyticKey
    cpu: cpu
    // memoryGB: memoryGB
    frontendContainerName: frontendContainerName
    frontendContainerImage: frontendContainerImage
    frontendPort: frontendPort
    backendContainerName: backendContainerName
    backendContainerImage: backendContainerImage
    backendPort: backendPort
    databaseContainerName: databaseContainerName
    databaseContainerImage: databaseContainerImage
    databasePort: databasePort
    postgresUser: postgresUser
    postgresPassword: postgresPassword
    postgresDatabase: postgresDatabase
    postgresHost: postgresHost
    postgresPort: postgresPort
    storageAccountName: storageAccountName
    appGatewaySubnetId: virtualNetwork.outputs.appGatewaySubnetId
  }
}

module networkSecurityGroup './networkSecurity.bicep' = {
  scope: resourceGroup
  name: networkSecurityGroupName
  params: {
    networkSecurityGroupName: networkSecurityGroupName
    location: location
    frontendPort: frontendPort
    backendPort: backendPort
    databasePort: databasePort
    internalSourceAddressPrefix: internalSourceAddressPrefix
  }
}

module virtualNetwork './virtualNetwork.bicep' = {
  scope: resourceGroup
  name: virtualNetworkName
  params: {
    virtualNetworkName: virtualNetworkName
    location: location
    addressSpacePrefix: addressSpacePrefix
    appGatewaySubnetName: appGatewaySubnetName
    appGatewaySubnetAddressPrefix: appGatewaySubnetAddressPrefix
  }
}

module publicIP './publicIP.bicep' = {
  scope: resourceGroup
  name: publicIPName
  params: {
    publicIPName: publicIPName
    location: location
  }
}

// module ingressController './ingress.bicep' = {
//   scope: resourceGroup
//   name: ingressControllerName
//   params: {
//     ingressControllerName: ingressControllerName
//     location: location
//     ingressControllerSubnetId: virtualNetwork.outputs.appGatewaySubnetId
//     publicIPId: publicIP.outputs.publicIPId
//     frontendPort: frontendPort
//     backendIP: backendIP
//   }
// }
