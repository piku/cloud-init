# cloud-init

This repository holds the bare essentials to deploy [`piku`][piku] using [`cloud-init`][ci] on [Azure][az], Oracle Cloud and Ubuntu on bare metal, and is provided as a base example for adaptation to _any_ cloud provider or local hypervisor that supports `cloud-init` (like AWS, GCP, DigitalOcean, Scaleway, Oracle Cloud, etc. - it's been tested on all major providers and on KVM, LXD, and VMware as well).

## Contributing

You are encouraged to clone this repository, adapt it for your own infrastructure provider and file an issue letting us know about it. Pull requests should be for Azure alone, though, since it will be simpler and neater to have a separate repository for each cloud provider.

[az]: http://azure.microsoft.com/
[azcli]: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
[piku]: https://github.com/piku
[ci]: https://cloudinit.readthedocs.io
