#!/bin/bash
az cloud set --name azureusgovernment
az login --service-principal --username $SERVICE_PRINCIPAL_ID --password $SERVICE_PRINCIPAL_KEY --tenant $TENANT_ID

rg=$(az group show --resource-group CORE_RG)
st=$(az storage account show -g CORE_RG --name coregenstorageact)
kv=$(az keyvault show -g CORE_RG --name corekv)

if [[ -z $rg ]];then
    az group create --location usgovvirginia --name CORE_RG
fi

if [[ -z $st ]];then
    az storage account create --name coregenstorageact --resource-group CORE_RG
    az storage container create --name state --account-name coregenstorageact
    az lock create --name coreLock --resource-group CORE_RG --lock-type CanNotDelete
fi

if [[ -z $kv ]];then
    az keyvault create --resource-group CORE_RG --name corekv
    az keyvault secret set --name ADO-SP --vault-name corekv --value "$(client_secret)" --content-type "ClientID: ec4f5c99-be19-4b19-9bbb-aebe9a6adcab"
fi

vms=$(grep -d recurse -G '^ [a-z].*{' 'Azure/variables/' |  sed 's|.*.tfvars: ||g' | sed 's| = {||g')
i=0
arrIN=(${vms//;/ })
while [[ ${arrIN[$i]} != "" ]]
do
    echo "Checking password for" ${arrIN[$i]}
    s=$(az keyvault secret show --vault-name "corekv" --name ${arrIN[$i]})
    if [[ -z $s ]];then
      password=$(openssl rand -base64 32)
      az keyvault secret set --vault-name "corekv" --name ${arrIN[$i]} --value "$password"
    else
      echo "password already exists"
    fi

    ((i += 1))
done