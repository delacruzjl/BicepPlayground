# BicepPlayground

## Setup

Create a parameters json file and add the required parameters from main.bicep, you may ignore vmUser and vmPassword so you can securely provide the values from the command prompt

Resources will be created following the Azure Naming convention here: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming


```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "projectName": {
            "value": "anything"
        },
        "environment": {
            "value": "devOrProdOrStaging"
        },
        "instance": {
            "value": "001OrAnyNumberSequence"
        },
        "location":{
            "value": "ValidAzureRegion"
        }
    }
}
```

## Deploy

```powershell
az deployment sub create -n YourDeploymentName \
--location ValidAzureRegion \
--template-file PathTo/main.bicep \
--parameters @PathToParameters.json
```
