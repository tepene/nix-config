{pkgs, gnomeExtensions, ...}: {
    # GNOME | https://nixos.org/manual/nixos/stable/#sec-gnome-enable
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.gnome.core-utilities.enable = false;

    # GTK/Qt themes | https://nixos.org/manual/nixos/stable/#sec-x11-gtk-and-qt-themes
    qt.enable = true;
    qt.platformTheme = "gtk2";
    qt.style = "gtk2";

    # dConf | https://gvolpe.com/blog/gnome3-on-nixos/
    dbus.packages = [ pkgs.gnome3.dconf ];
    udev.packages = [ pkgs.gnome3.gnome-settings-daemon ];

    # System packages
    environment.systemPackages = [
        # Basic Packages
        pkgs.gnome.gedit
        pkgs.kitty
        pkgs.nano
        # Themes
        pkgs.yaru-theme
        # Fonts
        pkgs.nerdfonts
        # Gnome Extenstions
        pkgs.gnome3.gnome-tweak-tool
        # gnomeExtensions.dash-to-dock
    ];
}