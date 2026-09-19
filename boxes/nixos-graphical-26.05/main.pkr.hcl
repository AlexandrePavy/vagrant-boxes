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

source "qemu" "nixos" {
  iso_url      = "https://channels.nixos.org/nixos-26.05/latest-nixos-minimal-x86_64-linux.iso"
  iso_checksum = "sha256:89bd369cb37bd8c65e5abd247eec30510a2f8cb9cc233a917e187aec41d01a88"

  headless         = false
  output_directory = "${path.root}/builds/nixos-graphical-26.05-qemu"

  vm_name     = "nixos-graphical-26.05"
  cpus        = var.cpus
  memory      = var.memory
  accelerator = "kvm"

  disk_size = 20480

  http_directory = "${path.root}/http"

  boot_wait = "30s"
  boot_command = [
    "mkdir -m 0700 .ssh<enter>",
    "curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/vagrant.pub.ed25519 > .ssh/authorized_keys<enter>",
    "sudo systemctl start sshd<enter>",
  ]

  ssh_username         = "nixos"
  ssh_private_key_file = "${path.root}/http/vagrant.key.ed25519"
  ssh_timeout          = "60m"

  shutdown_command = "sudo shutdown -h now"
}

build {
  sources = ["source.qemu.nixos"]

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} bash '{{ .Path }}'"
    script          = "${path.root}/scripts/install.sh"
  }

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} bash '{{ .Path }}'"
    script          = "${path.root}/scripts/clean.sh"
  }

  post-processor "vagrant" {
    compression_level = 6
    output            = "${path.root}/builds/nixos-graphical-26.05-{{.Provider}}.box"
  }
}