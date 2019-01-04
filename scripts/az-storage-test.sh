#!/usr/bin/env bash

### Functions ###
createResource() {
    echo "Creating resource"

    az group create --name testResources --location eastus

    az storage account create \
    --name pafstorage001 \
    --resource-group testResources \
    --location eastus \
    --sku Standard_LRS
    
    STORAGE_KEY=`az storage account keys list \
    --account-name pafstorage001 \
    --resource-group testResources | jq -r '.[0].value'`

    az storage container create --name pafstoragecontainer \
    --account-name pafstorage001 \
    --account-key $STORAGE_KEY

    head -c 5MB /dev/urandom > testfile.txt

    az storage blob upload \
    --container-name pafstoragecontainer \
    --name testblob \
    --file testfile.txt \
    --account-name pafstorage001 \
    --account-key $STORAGE_KEY

    rm testfile.txt

    #az vm create \
    #    --resource-group testResources \
    #    --name testVM \
    #    --image CentOS \
    #    --admin-username pafuser \
    #    --generate-ssh-keys

    #az vm open-port --port 80 --resource-group testResources --name testVM

    # Test running a command
    #az vm run-command invoke \
    #    --resource-group testResources \
    #    --name testVM \
    #    --command-id RunShellScript \
    #    --scripts "sudo yum install git -y"
}

deleteResource() {
    echo "Deleting resource"
    az group delete --name testResources -y
}

### MAIN ###
USAGE="USAGE: --create(-c), --delete(-d)"

if [ $# -eq 0 ]; then
    echo $USAGE
fi

# Switch between modes using flags
while [ ! $# -eq 0 ]
do
	case "$1" in
		--create | -c)
			createResource
			exit
			;;
		--delete | -d)
			deleteResource
			exit
			;;
		*)
		    echo $USAGE
		    exit
		    ;;
	esac
	shift
done




