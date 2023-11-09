{services, pkgs, ...}: {
    # GNOME without the apps
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.gnome.core-utilities.enable = false;
    # System packages
    environment.systemPackages = [
        # Basic Packages
        pkgs.flatpak
        pkgs.gnome.gedit
        pkgs.kitty
        pkgs.nano
        # Themes
        pkgs.yaru-theme
        # Fonts
        pkgs.nerdfonts
        # Gnome Extenstions
        gnomeExtensions.dash-to-dock
    ];
}