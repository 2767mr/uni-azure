@description('Location of the tile server container app.')
param location string

/* Dependencies */
@description('Id of the container app environment this container is deployed to.')
param containerAppEnvId string
/**************************************************/

/* Container app parameters */
@description('Name of the container in the container app environment.')
param tilesContainerName string

@description('The container image to pull for the tile server container app.')
param tilesContainerImage string

@description('Exposed port of the tile server container app.')
param tilesPort int
/**************************************************/

/* Container app requests */
@description('CPU quota for the tile server container app.')
param cpu int

@description('Memory quota for the tile server container app.')
param memory string
/**************************************************/

/* Container environemnt variables */
@description('Connection URL for connecting to the databse.')
param databaseConnectionURL string
/**************************************************/

resource tilesContainerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: tilesContainerName
  location: location
  properties: {
    environmentId: containerAppEnvId
    configuration: {
      ingress: {
        external: false
        targetPort: tilesPort
        exposedPort: tilesPort
        transport: 'tcp'
      }
    }
    template: {
      containers: [
        {
          name: tilesContainerName
          image: tilesContainerImage
          resources: {
            cpu: cpu
            memory: memory
          }
          env: [
            {
              name: 'DATABASE_URL'
              value: databaseConnectionURL
            }
          ]
        }
      ]
      scale: {
        minReplicas: 3
        maxReplicas: 10
      }
    }
  }
}
