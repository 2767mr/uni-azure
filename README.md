# Web-app deployment with BICEP

The main bicep file `main.bicep` creates a resource group which then contains all the resources. These are a log analytics workspace, public ip, virtual network, network security group and container group.

There is also a app gateway (called ingress-controller), which currently breaks the deployment, so it is commented out for now.

Th containers keep restarting for some reason. The container group should start all containers and keep them running to make the appliation avaiable throught the defined public ip.

The currently deployed app is the demo application from the martin server repository.

## How to deploy

Navigate to the directory containing the main bicep file and execute the following command:
`az deployment sub create --template-file main.bicep -l westeurope`
This deploys the resource group defined in main.bicep in the westeurope region to the currently logged in users azure account.

This requires the Azure CLI and the Bicep CLI to be available on the system and a user to be logged in with `az login`.

To check if Azure CLI/Bicep CLI is available run `az version`/`az bicep version`.
