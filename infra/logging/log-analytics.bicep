@description('Location of the log analytics workspace.')
param location string

@description('Name of the log analytics workspace.')
param logAnalyticsName string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

@description('Customer id of the log analytics workspace.')
output logAnalyticsCustomerId string = logAnalytics.properties.customerId

@description('Primary shared key of the log analytics workspace.')
output logAnalyticsSharedKey string = logAnalytics.listKeys().primarySharedKey
