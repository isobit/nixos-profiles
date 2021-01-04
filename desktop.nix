{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome3.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-panel
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.system-monitor
    numix-cursor-theme
    numix-icon-theme-square
    numix-sx-gtk-theme
    xclip
  ];

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
  ];

  services = {
    avahi = {
      # Enables mDNS with .local domain support
      enable = true;
      nssmdns = true;
    };
    locate.enable = true; # Periodically update the "locate" database
    printing.enable = true;
    xbanish.enable = true; # Hide cursor when typing
    xserver = {
      enable = true;

      # Keyboard settings
      layout = "us";
      xkbOptions = "caps:escape"; # Turn caps lock into another escape key

      displayManager.gdm.enable = true;

      desktopManager.gnome3 = {
        enable = true;
        extraGSettingsOverrides =
          let workspaces = map toString (lib.lists.range 1 9);
          in ''
            [org.gnome.desktop.wm.preferences]
            button-layout=':minimize,maximize,close'

            [org.gnome.desktop.wm.keybindings]
            close=['<Alt>w']
            toggle-maximized=['<Alt>Plus']
            ${lib.strings.concatMapStringsSep "\n" (i: "switch-to-workspace-${i}=['<Alt>${i}']") workspaces}
            ${lib.strings.concatMapStringsSep "\n" (i: "move-to-workspace-${i}=['<Alt><Shift>${i}']") workspaces}
          '';
      };
    };
  };
}
