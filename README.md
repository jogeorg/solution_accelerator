# Azure Resource Accelerator

## Folder Structure

```your root folder
├───_terraform
│   └───<cofiguration files for app teams>
├───core
│   └───<cofiguration files for core services>
├───modules
│   └───<cofiguration files for various modules>
├───scripts
│   └───terraform.sh <execute script from here>
└───variables
    ├───core
    │  └───variables.tfvars
    └───sample
        └───variables.tfvars
```

## How to use this repository

1. execute the terraform.sh script from the scripts directory and provide the inputs of action and team to execute.

```
. ./terraform.sh plan core
```

> It is important to include the leading period mark before the script path. The leading period indicated to bash to execute the script in the current terminal, not a background terminal. This is required for setting and persisting environment variables.

2. the script will cd to the cofiguration directory and load the correct tfvars files from the team's variables folder.
   > The intent behind this execution strategy is to isolate the remote state files to the scope the team's resource group. Becuase resource groups and terraform state files have the idea _(SDLC / lifecylce)_ we can isolate the respectively. Thus when we target a change to the sample environment, we don't want to read or change things in the sample environment and vice versa.
