#!/bin/sh


#######################################################
# Read input
#######################################################
eval "$(jq -r '@sh "environment=\(.environment) client_id=\(.client_id) client_secret=\(.client_secret) tenant_id=\(.tenant_id) subscription_id=\(.subscription_id) resource_group_name=\(.resource_group_name) vnet_name=\(.vnet_name)"')"


#######################################################
# Authenticate to Azure
#######################################################
setAzureEnvironment=$(az cloud set --name $environment)
authenticateToAzure=$(az login --service-principal -u $client_id --password=$client_secret --tenant $tenant_id --subscription $subscription_id)


#######################################################
# Switch to Custom DNS
#######################################################
customDns=$(az network vnet update -g $resource_group_name -n $vnet_name --dns-servers null --subscription $subscription_id)
sleep 60

jq -n --arg customDns "$customDns" '{"customDns":$customDns}'
