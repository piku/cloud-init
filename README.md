# cloud-init

This repository holds the bare essentials to deploy [`piku`][piku] on Ubuntu LTS through [`cloud-init`][ci] on  _any_ cloud provider or local hypervisor that supports it.

> ⚠️ **Warning**
>
> These are not meant to be used as guides for manual installation. The files are provided as starting points only, and may require tweaking depending on your environment. Variations of this have been used in [Azure][az], AWS, GCP, DigitalOcean, Scaleway, Oracle Cloud and other public cloud providers, as well as KVM, LXD, and VMware as well, but be prepared to iterate a bit.

## Quick Hacks

If you want to use these files to provision an already running machine, this should work (it steps through the cloud-init modules required):

```bash
sudo cloud-init clean --logs
sudo cloud-init --file cloud-init.yml single --name cc_package_update_upgrade_install --frequency once 
sudo cloud-init --file cloud-init.yml single --name cc_write_files --frequency once 
sudo sh /var/lib/cloud/instances/iid-datasource-none/scripts/runcmd
```

## Contributing

You are encouraged to clone this repository, adapt it for your own infrastructure provider and file a pull request with versions that work for your own environment.

[az]: http://azure.microsoft.com/
[azcli]: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
[piku]: https://github.com/piku
[ci]: https://cloudinit.readthedocs.io
