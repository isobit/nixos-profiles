{ config, lib, pkgs, ... }:

{
  # Unfree needed for firefox-bin
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # GNOME extensions
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-panel
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.system-monitor

    # GNOME apps
    gnome3.gnome-tweaks

    # Numix theme
    numix-cursor-theme
    numix-icon-theme-square
    numix-sx-gtk-theme

    # Applications
    firefox-bin
    libreoffice

    # Command-line utils
    trash-cli
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
    locate.enable = true; # Periodically update the "locate" database
    xbanish.enable = true; # Hide cursor when typing

    avahi = {
      # Enables mDNS with .local domain support
      enable = true;
      nssmdns = true;
    };

    printing = {
      enable = true;
      drivers = with pkgs; [ gutenprintBin ];
    };

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
