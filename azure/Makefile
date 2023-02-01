export SHELL=/bin/bash
export RESOURCE_GROUP?=paas
export LOCATION?=eastus2
export MACHINE_NAME?=paas
export DNS_NAME:=$(MACHINE_NAME)-$(RESOURCE_GROUP)
export FQDN:=$(DNS_NAME).$(LOCATION).cloudapp.azure.com
export SSH_PORT:=22
export ADMIN_USERNAME?=$(notdir $(HOME))
export TIMESTAMP:=$(shell date "+%Y-%m-%d-%H-%M-%S")
export STORAGE_SUFFIX:=$(shell date "+%m%d%H")
export STORAGE_ACCOUNT_NAME:=$(MACHINE_NAME)diag$(STORAGE_SUFFIX)
export VM_SIZE:=Standard_B2ms
export OS_DISK_SIZE:=32
export OS_DISK_SKU:=StandardSSD_LRS
export VM_IMAGE:=Canonical:0001-com-ubuntu-minimal-jammy:minimal-22_04-lts-gen2:latest
export SSH:=ssh -q -A $(ADMIN_USERNAME)@$(FQDN) -p $(SSH_PORT) -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

# Permanent local overrides
-include .env
.DEFAULT_GOAL := help

list-resources: ## Dump resource groups
	az group list --output table

list-locations: ## Dump list of location IDs
	az account list-locations --output table

list-sizes: ## Dump list of VM sizes in the selected location
	az vm list-sizes --location=$(LOCATION) --output table

list-image-offers: ## Dump list of OS image offers
	az vm image list-offers --location=$(LOCATION) --publisher Canonical --output table

list-image-skus: ## Dump list of OS image SKUs
	az vm image list-skus --location=$(LOCATION) --publisher Canonical --offer 0001-com-ubuntu-server-jammy --output table --output table 

preflight: ## Create the empty resource group
	az group create \
		--name $(RESOURCE_GROUP) \
		--location $(LOCATION) \
		--output table 

deploy-storage: ## Deploy a storage account for diagnostics and restic backups
	az storage account create \
		--name $(STORAGE_ACCOUNT_NAME) \
		--resource-group $(RESOURCE_GROUP) \
		--kind StorageV2 \
		--sku Standard_LRS

deploy-network: ## Deploy the network and open network security group ports
	az network nsg create \
		--name $(MACHINE_NAME) \
		--resource-group $(RESOURCE_GROUP) \
		--output table
	az network nsg rule create \
		--priority 1000 \
		--name allow-ssh \
		--access Allow \
		--direction Inbound \
		--protocol TCP \
		--destination-port-ranges $(SSH_PORT) \
		--nsg-name $(MACHINE_NAME) \
		--resource-group $(RESOURCE_GROUP) \
	    --output table
	az network nsg rule create \
		--priority 1001 \
		--name allow-http \
		--access Allow \
		--direction Inbound \
		--protocol TCP \
		--destination-port-ranges 80 \
		--nsg-name $(MACHINE_NAME) \
		--resource-group $(RESOURCE_GROUP) \
	    --output table
	az network nsg rule create \
		--priority 1002 \
		--name allow-https \
		--access Allow \
		--direction Inbound \
		--protocol TCP \
		--destination-port-ranges 443 \
		--nsg-name $(MACHINE_NAME) \
		--resource-group $(RESOURCE_GROUP) \
		--output table

deploy-compute: ## Deploy the VM only
	envsubst < cloud-init.yml > custom-data
	az vm create \
		--name $(MACHINE_NAME) \
		--os-disk-name $(MACHINE_NAME) \
		--os-disk-size-gb $(OS_DISK_SIZE) \
		--storage-sku $(OS_DISK_SKU) \
		--size $(VM_SIZE) \
		--admin-username $(ADMIN_USERNAME) \
		--ssh-key-value @$(HOME)/.ssh/id_rsa.pub \
		--public-ip-address-dns-name $(DNS_NAME) \
		--boot-diagnostics-storage $(STORAGE_ACCOUNT_NAME) \
		--custom-data @custom-data \
		--image $(VM_IMAGE) \
		--resource-group $(RESOURCE_GROUP) \
		--nsg $(MACHINE_NAME) \
		--output table \
		--no-wait
	rm custom-data

destroy-all: ## Destroy the entire resource group
	az group delete \
		--name $(RESOURCE_GROUP) \
		--no-wait \
		--yes

deploy: ## *START HERE* Deploy all the resources
	make preflight
	make deploy-storage
	make deploy-network
	make deploy-compute

redeploy: ## Destroy and redeploy [WARNING: this is for testing only!]
	-make destroy-all
	while [[ $$(az group list | grep Deleting) =~ "Deleting" ]]; do sleep 30; done
	make deploy

view-deployment: ## View deployment details
	az group deployment operation list \
		--resource-group $(RESOURCE_GROUP) \
		--query "[].{OperationID:operationId,Name:properties.targetResource.resourceName,Type:properties.targetResource.resourceType,State:properties.provisioningState,Status:properties.statusCode}" \
		--output table

# Do not output warnings, do not validate or add remote host keys (useful when doing successive deployments or going through a load balancer)
ssh: ## SSH into the VM (disabling strict host checking, for quick testing)
	$(SSH)

check-services: ## SSH into the VM and check services
	$(SSH) sudo systemctl status cgconfigparser
	$(SSH) sudo systemctl status cgrulesgend
	$(SSH) sudo systemctl status piku-nginx-watcher

list-endpoints: ## List open endpoints
	az network public-ip list \
		--resource-group $(RESOURCE_GROUP) \
		--query '[].{dnsSettings:dnsSettings.fqdn}' \
		--output table

help: ## This help
	@grep -hE '^[A-Za-z0-9_ \-]*?:.*##.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set: ## Dump current environment variables
	set