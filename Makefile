export RESOURCE_GROUP?=piku
export LOCATION?=eastus
export MACHINE_NAME?=paas
export DNS_NAME=$(MACHINE_NAME)-$(RESOURCE_GROUP)
export FQDN=$(DNS_NAME).$(LOCATION).cloudapp.azure.com
export ADMIN_USERNAME?=$(USER)
export SHELL=/bin/bash
export TIMESTAMP=$(shell date "+%Y-%m-%d-%H-%M-%S")
export STORAGE_SUFFIX=$(shell date "+%d%H%M")
export STORAGE_ACCOUNT_NAME=$(MACHINE_NAME)diag$(STORAGE_SUFFIX)
export VM_SIZE=Standard_B2ms


# Permanent local overrides
-include .env

# dump resource groups
resources:
	az group list --output table

# Dump list of location IDs
locations:
	az account list-locations --output table

sizes:
	az vm list-sizes --location=$(LOCATION) --output table

images:
	az vm list-images --output table

# Create a resource group and deploy the cluster resources inside it

preflight:
	az group create \
		--name $(RESOURCE_GROUP) \
		--location $(LOCATION) \
		--output table 

deploy-storage:
	az storage account create \
		--name $(STORAGE_ACCOUNT_NAME) \
		--resource-group $(RESOURCE_GROUP) \
		--kind StorageV2 \
		--sku Standard_LRS

deploy-network:
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
		--destination-port-ranges 22 \
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

deploy-compute:
	az vm create \
		--name $(MACHINE_NAME) \
		--os-disk-name $(MACHINE_NAME) \
		--os-disk-size-gb 32 \
		--size $(VM_SIZE) \
		--admin-username $(USER) \
		--ssh-key-value @$(HOME)/.ssh/id_rsa.pub \
		--public-ip-address-dns-name $(DNS_NAME) \
		--boot-diagnostics-storage $(STORAGE_ACCOUNT_NAME) \
        --custom-data @cloud-init.yml \
		--image UbuntuLTS \
		--resource-group $(RESOURCE_GROUP) \
		--nsg $(MACHINE_NAME) \
		--output table \
		--no-wait

# Destroy the entire resource group and all cluster resources
destroy-all:
	az group delete \
		--name $(RESOURCE_GROUP) \
		--no-wait \
		--yes

deploy:
	make preflight
	make deploy-storage
	make deploy-network
	make deploy-compute

redeploy:
	-make destroy-all
	while [[ $$(az group list | grep Deleting) =~ "Deleting" ]]; do sleep 30; done
	make deploy

# View deployment details
view-deployment:
	az group deployment operation list \
		--resource-group $(RESOURCE_GROUP) \
		--query "[].{OperationID:operationId,Name:properties.targetResource.resourceName,Type:properties.targetResource.resourceType,State:properties.provisioningState,Status:properties.statusCode}" \
		--output table

# Do not output warnings, do not validate or add remote host keys (useful when doing successive deployments or going through the load balancer)
ssh:
	ssh -q -A $(ADMIN_USERNAME)@$(FQDN) -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

# List endpoints
list-endpoints:
	az network public-ip list \
		--resource-group $(RESOURCE_GROUP) \
		--query '[].{dnsSettings:dnsSettings.fqdn}' \
		--output table
