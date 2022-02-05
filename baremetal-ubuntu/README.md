# Install Piku on Ubuntu 20.04 using `cloud-init`

> ℹ️ **Note** 
> 
> This assumes you're using [the official Raspberry Pi Ubuntu images](https://ubuntu.com/download/raspberry-pi) for Ubuntu 20.04 (current LTS). It _is not guaranteed to work_ on other versions

## Fully Automated Setup

After flashing the new SD Card, save the `cloud-init.yml` folder as `system-boot/user-data`.

## Semi-Manual Setup

After first boot, log in to your Pi, copy the `cloud-init.yml` file to it and type:

```bash
sudo rm -rf /var/lib/cloud/instances/nocloud
cd /boot/firmware
sudo cp user-data user-data.original
sudo cp ~/cloud-init.yml user-data
sudo reboot
```

`cloud-init` will then provision your system.

## TODO:

- [ ] Automatically resize the main partition by using `fdisk /dev/mmcblk0`, deleting the second partition, re-creating it for the full volume _and then_ writing it
- [ ] Move all the log volumes/other housekeeping stuff to `tmpfs` to lessen SD card wear

