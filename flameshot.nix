{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    flameshot
    gnomeExtensions.appindicator
  ];
  services.dbus.packages = with pkgs; [ flameshot ];
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.settings-daemon.plugins.media-keys]
    screenshot=[]

    [org.gnome.settings-daemon.plugins.media-keys]
    custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-flameshot/']

    [org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-flameshot/]
    name='flameshot'
    command='flameshot gui'
    binding='Print'
  '';
}
