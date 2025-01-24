@description('Location of the storage account.')
param location string

@description('Name of the storage account.')
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
  name: 'database-share'
  parent: storageAccountFS
  properties: {
    // enabledProtocols: 'NFS'
  }
}

@description('Key of the storage ayyount.')
output storageAccountKey string = storageAccount.listKeys().keys[0].value
