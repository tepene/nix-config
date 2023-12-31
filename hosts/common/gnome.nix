{pkgs, gnomeExtensions, ...}: {
    # GNOME without the apps
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
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
        # gnomeExtensions.dash-to-dock
    ];
}