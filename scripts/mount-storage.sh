#!/usr/bin/env bash

RESOURCE_GROUP=$1
STORAGE_ACCOUNT=$2
CONTAINER_NAME=$3
VM_NAME=$4

STORAGE_KEY=`az storage account keys list \
    --account-name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP | jq -r '.[0].value'`

az vm run-command invoke \
        --resource-group $RESOURCE_GROUP \
        --name $VM_NAME \
        --command-id RunShellScript \
        --scripts "sudo rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm" \
            "sudo yum install blobfuse -y" \
            "sudo mkdir /mnt/resource/blobfusetmp" \
            "sudo chown azureadmin /mnt/resource/blobfusetmp" \
            "mkdir /home/azureadmin/.blobfuse" \
            "touch /home/azureadmin/.blobfuse/fuse_connection.cfg" \
            "echo -e 'accountName $STORAGE_ACCOUNT\naccountKey $STORAGE_KEY\ncontainerName $CONTAINER_NAME' > /home/azureadmin/.blobfuse/fuse_connection.cfg" \
            "chmod 700 /home/azureadmin/.blobfuse/fuse_connection.cfg" \
            "mkdir /home/azureadmin/mycontainer" \
            "sudo blobfuse /home/azureadmin/mycontainer --tmp-path=/mnt/resource/blobfusetmp  --config-file=/home/azureadmin/.blobfuse/fuse_connection.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120"

