
@description('Location of the postgres container app.')
param location string

/* Dependencies */
@description('Id of the container app environment this container is deployed to.')
param containerAppEnvId string
/**************************************************/

/* Container app parameters */
@description('Name of the container in the container app environment.')
param postgresContainerName string

@description('The container image to pull for the postgres container app.')
param postgresContainerImage string

@description('Exposed port of the postgres container app.')
param postgresPort int
/**************************************************/

/* Container app requests */
@description('CPU quota for the postgres container app.')
param cpu int

@description('Memory quota for the postgres container app.')
param memory string
/**************************************************/

/* Container environemnt variables */
@description('Name of the postgres database user in the container app.')
param postgresUser string

@description('Password of the postgres database user in the container app.')
@secure()
param postgresPassword string

@description('Name of the postgres database in the container app.')
param postgresDatabase string
/**************************************************/

resource postgresContainerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: postgresContainerName
  location: location
  // Would be needed if database is stored on a shared storage
  // dependsOn: [
  //  storage
  // ]
  properties: {
    environmentId: containerAppEnvId
    configuration: {
      ingress: {
        external: false
        targetPort: postgresPort
        exposedPort: postgresPort
        transport: 'tcp'
      }
    }
    template: {
      containers: [
        {
          name: postgresContainerName
          image: postgresContainerImage
          resources: {
            cpu: cpu
            memory: memory
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
          // Could not figure out how to make volume mounts work for postgres (see below for explanation)
          // volumeMounts: [
          //   {
          //     volumeName: 'database-volume'
          //     mountPath: '/var/lib/postgresql/data'
          //   }
          // ]
        }
      ]
      scale: {
        // Technically it does not make sense to have more than one db replica as there is no files share.
        // Each replica could potentially provide different data.
        // However, the application builds only static data from the database.
        // Therefore, as long as we do not want to update the database this works.
        minReplicas: 3
        maxReplicas: 10
      }
      // This would be required to add a file share volume to store the database data.
      // However, postgres requires hard-links which is not supported by the storageType 'AzureFile'.
      // And the storageType 'NfsAzureFile' did not seem to work with the student account.
      //
      // volumes: [
      //   {
      //     name: 'database-volume'
      //     storageName: 'asdfstorage'
      //     // storageType: 'AzureFile'
      //     mountOptions: 'uid=999,gid=999,dir_mode=0750,file_mode=0750,mfsymlinks,nobrl,cache=none'
      //     storageType: 'NfsAzureFile'
      //   }
      // ]
    }
  }
}
