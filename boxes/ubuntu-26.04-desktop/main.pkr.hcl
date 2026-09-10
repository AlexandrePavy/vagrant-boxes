packer {
  required_version = ">= 1.16.0"

  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }

    vagrant = {
      version = "~> 1"
      source  = "github.com/hashicorp/vagrant"
    }

  }
}

variable "cpus" {
  type        = number
  default     = 4
  description = "Number of virtual CPUs allocated to the build VM."
}

variable "memory" {
  type        = number
  default     = 4096
  description = "Amount of memory allocated to the build VM."
}

source "qemu" "ubuntu-desktop" {
  iso_url      = "https://releases.ubuntu.com/26.04/ubuntu-26.04-desktop-amd64.iso"
  iso_checksum = "sha256:487f87faaf547ea30e0aba4d5b53346292571256b25333a978db1692bcee9dd2"

  headless         = true
  output_directory = "${path.root}/builds/ubuntu-desktop-26.04-amd64-qemu"

  vm_name     = "ubuntu-desktop-26.04-amd64"
  cpus        = var.cpus
  memory      = var.memory
  accelerator = "kvm"

  disk_size = 20480

  http_directory = "${path.root}/http"

  boot_wait = "5s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz autoinstall ds=\"nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\"<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter><wait>"
  ]

  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout  = "60m"

  shutdown_command = "sudo shutdown -P now"
}

build {
  sources = ["source.qemu.ubuntu-desktop"]

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} bash '{{ .Path }}'"
    script          = "${path.root}/scripts/clean.sh"
  }

  post-processor "vagrant" {
    compression_level = 6
    output            = "${path.root}/builds/ubuntu-26.04-desktop-amd64-{{.Provider}}.box"
  }
}