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

source "qemu" "ubuntu" {
  iso_url      = "https://cdimage.ubuntu.com/ubuntu/stonking/daily-live/20261010/stonking-desktop-amd64.iso"
  iso_checksum = "sha256:223dba784b79fe14fc5bf2351cebf66cc99126a333a34f773beedbe1be44730b"

  headless         = true
  output_directory = "${path.root}/builds/ubuntu-26.10-desktop-amd64-qemu"

  vm_name     = "ubuntu-26.10-desktop"
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
  sources = ["source.qemu.ubuntu"]

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} bash '{{ .Path }}'"
    script          = "${path.root}/scripts/clean.sh"
  }

  post-processor "vagrant" {
    compression_level = 6
    output            = "${path.root}/builds/ubuntu-26.10-desktop-amd64-{{.Provider}}.box"
  }
}