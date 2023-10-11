#!/bin/bash
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

case $1 in
    "plan"|"apply"|"refresh"|"destroy"|"validate")
        ;;
    *)
        echo 'Expected one of "plan"|"apply"|"refresh"|"destroy"|"validate"'
        echo "Recieved \"$1\""
        return
esac

case $2 in
    "sample"|"core"|"test")
        ;;
    *)
        echo 'Expected one of "sample"|"core"|"test"'
        echo "Recieved \"$2\""
        return
esac

case $3 in
    "dev"|"uat"|"")
        ;;
    *)
    return
esac

TEAM="$2"
MY_ACTION="$1"

#To be dynamically updated in the future
export be_rg_name="CORE_RG"
export be_st_name="coregenstorageact"
export subscription=""
export be_key="${TEAM}${env}.tfstate"
export client_id=""
export tenant_id=""
export TF_VAR_client_secret="$SERVICE_PRINCIPAL_KEY"
#end

# Get state info for future use
echo "##vso[task.setvariable variable=BE_KEY;]$be_key"
# esu erutuf rof ofni etats teG


echo "$BASH_SOURCE: Executing input action $MY_ACTION" 

if [[ $TEAM = "core" ]];then
    cd ../core
else
    cd ../_terraform
fi

case $MY_ACTION in
    "plan")
        terraform init \
            --backend-config="resource_group_name=$be_rg_name" \
            --backend-config="environment=usgovernment" \
            --backend-config="storage_account_name=$be_st_name" \
            --backend-config="container_name=state" \
            --backend-config="key=$be_key" \
            --backend-config="subscription_id=$subscription" \
            --backend-config="client_id=$client_id" \
            --backend-config="client_secret=$TF_VAR_client_secret" \
            --backend-config="tenant_id=$tenant_id" -reconfigure
        terraform plan --var-file ../variables/${TEAM}/variables.tfvars --var-file ../variables/${TEAM}/${env}/variables.tfvars
        ;;
    "apply")
        count=0
        terraform init \
            --backend-config="resource_group_name=$be_rg_name" \
            --backend-config="environment=usgovernment" \
            --backend-config="storage_account_name=$be_st_name" \
            --backend-config="container_name=state" \
            --backend-config="key=$be_key" \
            --backend-config="subscription_id=$subscription" \
            --backend-config="client_id=$client_id" \
            --backend-config="client_secret=$TF_VAR_client_secret" \
            --backend-config="tenant_id=$tenant_id" -reconfigure
        terraform apply --var-file ../variables/${TEAM}/variables.tfvars --var-file ../variables/${TEAM}/${env}/variables.tfvars -auto-approve
        # Second Rule Of Zombieland
        if [[ $? -ne 0 && $count -lt 3 ]];then
            ((count++))
            terraform init \
                --backend-config="resource_group_name=$be_rg_name" \
                --backend-config="environment=usgovernment" \
                --backend-config="storage_account_name=$be_st_name" \
                --backend-config="container_name=state" \
                --backend-config="key=$be_key" \
                --backend-config="subscription_id=$subscription" \
                --backend-config="client_id=$client_id" \
                --backend-config="client_secret=$TF_VAR_client_secret" \
                --backend-config="tenant_id=$tenant_id" -reconfigure
            terraform apply --var-file ../variables/${TEAM}/variables.tfvars --var-file ../variables/${TEAM}/${env}/variables.tfvars -auto-approve
        fi
        ;;
    "refresh")
        terraform init \
            --backend-config="resource_group_name=$be_rg_name" \
            --backend-config="environment=usgovernment" \
            --backend-config="storage_account_name=$be_st_name" \
            --backend-config="container_name=state" \
            --backend-config="key=$be_key" \
            --backend-config="subscription_id=$subscription" \
            --backend-config="client_id=$client_id" \
            --backend-config="client_secret=$TF_VAR_client_secret" \
            --backend-config="tenant_id=$tenant_id" -reconfigure
        terraform refresh --var-file ../variables/${TEAM}/variables.tfvars --var-file ../variables/${TEAM}/${env}/variables.tfvars
        ;;
    "destroy")
        terraform init \
            --backend-config="resource_group_name=$be_rg_name" \
            --backend-config="environment=usgovernment" \
            --backend-config="storage_account_name=$be_st_name" \
            --backend-config="container_name=state" \
            --backend-config="key=$be_key" \
            --backend-config="subscription_id=$subscription" \
            --backend-config="client_id=$client_id" \
            --backend-config="client_secret=$TF_VAR_client_secret" \
            --backend-config="tenant_id=$tenant_id" -reconfigure
        terraform destroy --var-file ../variables/${TEAM}/variables.tfvars --var-file ../variables/${TEAM}/${env}/variables.tfvars -auto-approve
        # Second Rule Of Zombieland
        if [[ $? -ne 0 && $count -lt 3 ]];then
            ((count++))
            terraform init \
                --backend-config="resource_group_name=$be_rg_name" \
                --backend-config="environment=usgovernment" \
                --backend-config="storage_account_name=$be_st_name" \
                --backend-config="container_name=state" \
                --backend-config="key=$be_key" \
                --backend-config="subscription_id=$subscription" \
                --backend-config="client_id=$client_id" \
                --backend-config="client_secret=$TF_VAR_client_secret" \
                --backend-config="tenant_id=$tenant_id" -reconfigure
        terraform destroy --var-file ../variables/${TEAM}/variables.tfvars --var-file ../variables/${TEAM}/${env}/variables.tfvars -auto-approve
        fi
        ;;
    "validate")
        terraform init \
            --backend-config="resource_group_name=$be_rg_name" \
            --backend-config="environment=usgovernment" \
            --backend-config="storage_account_name=$be_st_name" \
            --backend-config="container_name=state" \
            --backend-config="key=$be_key" \
            --backend-config="subscription_id=$subscription" \
            --backend-config="client_id=$client_id" \
            --backend-config="client_secret=$TF_VAR_client_secret" \
            --backend-config="tenant_id=$tenant_id" -reconfigure
        terraform validate
        ;;     
esac
cd -
