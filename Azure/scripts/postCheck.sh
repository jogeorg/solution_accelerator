#!/bin/bash
az cloud set --name azureusgovernment
az login --service-principal --username $SERVICE_PRINCIPAL_ID --password $SERVICE_PRINCIPAL_KEY --tenant $TENANT_ID

# break lease lock if exists
rg=$(az group show --resource-group CORE_RG | grep name | sed 's|"name": "||g' | sed 's|",||g')
st=$(az storage account list --resource-group $rg | grep name | sed '/"name": "/q' | sed 's|"name": "||g' | sed 's|",||g' | sed 's| *||g')
ctx=$(az storage account show-connection-string --resource-group $rg --name $st --query connectionString -o tsv)

az storage blob lease break --blob-name $BE_KEY --container-name state --connection-string $ctx || true