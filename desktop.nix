{ config, lib, pkgs, ... }:

let
  enabledGnomeExtensionPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-panel
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.system-monitor
  ];
in
{
  # Unfree needed for firefox-bin
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # GNOME apps
    gnome.gnome-tweaks

    # Numix theme
    numix-cursor-theme
    numix-icon-theme-square
    numix-sx-gtk-theme

    # Applications
    alacritty
    chromium
    firefox-bin
    gnome.gnome-photos
    libreoffice
    spotify

    # Command-line utils
    graphviz
    hwinfo
    pandoc
    trash-cli
    xclip
  ] ++ enabledGnomeExtensionPackages;

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
      enable = lib.mkDefault true;
      nssmdns = lib.mkDefault true;
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

      desktopManager.gnome = {
        enable = true;
        extraGSettingsOverrides =
          let
            workspaces = map toString (lib.lists.range 1 9);
          in ''
            [org.gnome.desktop.wm.preferences]
            button-layout=':minimize,maximize,close'

            [org.gnome.desktop.wm.keybindings]
            close=['<Alt>w']
            toggle-maximized=['<Alt>Plus']
            ${lib.strings.concatMapStringsSep "\n" (i: "switch-to-workspace-${i}=['<Alt>${i}']") workspaces}
            ${lib.strings.concatMapStringsSep "\n" (i: "move-to-workspace-${i}=['<Alt><Shift>${i}']") workspaces}

            [org.gnome.settings-daemon.plugins.color]
            night-light-enabled=true

            [org.gnome.shell]
            enabled-extensions=[${lib.strings.concatMapStringsSep "," (p: "'${p.extensionUuid}'") enabledGnomeExtensionPackages}]
          '';
      };
    };
  };
}
