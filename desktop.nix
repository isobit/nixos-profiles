{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    numix-cursor-theme
    numix-icon-theme-square
    numix-sx-gtk-theme
    xclip
  ];

  services = {

    locate.enable = true;

    printing.enable = true;

    gnome3.gnome-keyring.enable = true;

    xserver = {

      enable = true;
      layout = "us";
      xkbOptions = "caps:escape";

      displayManager.gdm.enable = true;

      desktopManager = {
        gnome3 = {
          enable = true;
          extraGSettingsOverrides = let
            workspaces = map toString (lib.lists.range 1 12);
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

  };

}
