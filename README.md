# Vagrant Boxes

| Box Name                           | Packer File                                                       | Box URL                                                             |
|------------------------------------|-------------------------------------------------------------------|---------------------------------------------------------------------|
| AlexandrePavy/ubuntu-26.04-desktop | [ubuntu-26.04-desktop](./boxes/ubuntu-26.04-desktop/main.pkr.hcl) | https://vagrant-boxes.s3.fr-par.scw.cloud/ubuntu-26.04-desktop.json |

## Vagrantfile

```
Vagrant.configure("2") do |config|
  config.vm.box = "AlexandrePavy/ubuntu-26.04-desktop"
  config.vm.box_url = "https://vagrant-boxes.s3.fr-par.scw.cloud/ubuntu-26.04-desktop.json"

  config.vm.provider "libvirt" do |libvirt|
    libvirt.cpus = 4
    libvirt.memory = 8192

    libvirt.graphics_type = "vnc"
    libvirt.video_type = "virtio"
    libvirt.keymap = "fr"
  end
end
```