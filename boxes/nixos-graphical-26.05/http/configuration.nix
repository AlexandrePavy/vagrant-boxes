{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";

  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Force la disposition AZERTY sous GNOME / X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  services.openssh.enable = true;
  services.timesyncd.enable = true;

  # Vagrant packages
  environment.systemPackages = with pkgs; [
  ];

  users.groups.vagrant = {};
  users.users.vagrant = {
    description = "Vagrant User";
    isNormalUser = true;

    group = "vagrant";

    extraGroups = [
      "users"
      "wheel"
    ];

    home = "/home/vagrant";
    createHome = true;
    useDefaultShell = true;

    password = "vagrant";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1YdxBpNlzxDqfJyw/QKow1F+wvG9hXGoqiysfJOn5Y vagrant insecure public key"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "26.05";
}
