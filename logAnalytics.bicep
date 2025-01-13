param location string
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

output logAnalyticsId string = logAnalytics.properties.customerId
output logAnalyticKey string = logAnalytics.listKeys().primarySharedKey
