# Install Piku on Azure using `cloud-init`

## Requirements

* An [Azure][az] account
* GNU `make`
* The [`azure-cli`][azcli]
* An existing SSH public key in your `~/.ssh` folder 

## Usage

* Via CLI: Edit the `Makefile` to pick your deployment region and other preferences, then `make deploy`.
* Via the [Azure][az] portal: paste the `cloud-init.yml` file into the appropriate field when creating an Ubuntu LTS virtual machine (make sure you edit the network security groups to allow for HTTP(S) traffic afterwards).

## Notes

* This sets the VM admin username to your own and deploys your SSH public key automatically.
* The `cloud-init.yml` does all the heavy work, and can readily be adopted for other cloud providers (should be 100% re-usable other than the `waagent.conf` file, which is the only thing that is [Azure][az]-specific).
* The `Makefile` has appropriate sub-targets for deploying and destroying the required [Azure][az] resources.

## Caveats

* This would best be done as an Azure Resource Manager template, but using the CLI alone allows for easier experimentation and provides a more readable example.
* This will deploy everything on Ubuntu LTS 22.04 (which is one of the core distributions we test [`piku`][piku] against).

## `cgroup` management notes

This `cloud-init` template also sets up experimental `cgroup` management support that can be triggered by a custom `release` worker that rewrites `cgred.conf` and `cgconfig.d` in the `.piku` folder. This is meant to allow applications to self-limit CPU and RAM resources as a way to avoid pushing that overhead onto `piku` itself.

[az]: http://azure.microsoft.com/
[azcli]: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
[piku]: https://github.com/piku
[ci]: https://cloudinit.readthedocs.io
