#!/usr/bin/env bash

RESOURCE_GROUP=$1
STORAGE_ACCOUNT=$2
CONTAINER_NAME=$3

STORAGE_KEY=`az storage account keys list \
    --account-name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP | jq -r '.[0].value'`

sudo rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm 
sudo yum install blobfuse -y
sudo mkdir /mnt/resource/blobfusetmp
sudo chown pafuser /mnt/resource/blobfusetmp
mkdir /home/pafuser/.blobfuse
touch /home/pafuser/.blobfuse/fuse_connection.cfg
echo -e 'accountName $STORAGE_ACCOUNT\naccountKey $STORAGE_KEY\ncontainerName $CONTAINER_NAME' > /home/pafuser/.blobfuse/fuse_connection.cfg
chmod 700 /home/pafuser/.blobfuse/fuse_connection.cfg
mkdir /home/pafuser/mycontainer
sudo blobfuse /home/pafuser/mycontainer --tmp-path=/mnt/resource/blobfusetmp  --config-file=/home/pafuser/.blobfuse/fuse_connection.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120
