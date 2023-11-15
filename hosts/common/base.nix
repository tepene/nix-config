# Basic settings
{ config, pkgs, ... }:

{
  # Time zone
  time.timeZone = "Europe/Zurich";

  # Internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_CH.UTF-8";
    LC_IDENTIFICATION = "de_CH.UTF-8";
    LC_MEASUREMENT = "de_CH.UTF-8";
    LC_MONETARY = "de_CH.UTF-8";
    LC_NAME = "de_CH.UTF-8";
    LC_NUMERIC = "de_CH.UTF-8";
    LC_PAPER = "de_CH.UTF-8";
    LC_TELEPHONE = "de_CH.UTF-8";
    LC_TIME = "de_CH.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "ch";
    xkbVariant = "de_nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "sg";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Flatpak | https://nixos.org/manual/nixos/stable/#module-services-flatpak
  services.flatpak.enable = true;
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    home-manager
    just
    nano
    btop
    podman
    podman-compose
    zsh
    syncthing
  ];
}
