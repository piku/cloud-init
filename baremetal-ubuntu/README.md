# Install Piku on Ubuntu using `cloud-init`

This assumes you're using [the official Ubuntu images](https://ubuntu.com/download/raspberry-pi) for Ubuntu 20.04 (current LTS).

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