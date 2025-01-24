@description('Location of the UI container app.')
param location string

/* Dependencies */
@description('Id of the container app environment this container is deployed to.')
param containerAppEnvId string
/**************************************************/

/* Container app parameters */
@description('Name of the container in the container app environment.')
param uiContainerName string

@description('The container image to pull for the UI container app.')
param uiContainerImage string

@description('Exposed port of the UI container app.')
param uiPort int
/**************************************************/

/* Container app requests */
@description('CPU quota for the UI container app.')
param cpu int

@description('Memory quota for the UI container app.')
param memory string
/**************************************************/


resource uiContainerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: uiContainerName
  location: location
  properties: {
    environmentId: containerAppEnvId
    configuration: {
      ingress: {
        external: true
        targetPort: uiPort
      }
    }
    template: {
      containers: [
        {
          name: uiContainerName
          image: uiContainerImage
          resources: {
            cpu: cpu
            memory: memory
          }
        }
      ]
      scale: {
        minReplicas: 3
        maxReplicas: 10
      }
    }
  }
}

@description('Fully qualified dmain name of the ui container app.')
output uiFQDN string = uiContainerApp.properties.configuration.ingress.fqdn
