{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnomeExtensions.dash-to-panel
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
    avahi.enable = true;  # mDNS
    locate.enable = true;
    printing.enable = true;
    xbanish.enable = true; # Hide cursor when typing
    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "caps:escape";

      # Not using GDM because it causes issues with bluetooth audio
      displayManager.gdm.enable = true;
      # displayManager.lightdm = {
      #   enable = true;
      #   background = "#333333";
      #   greeters.gtk = {
      #     theme.name = "Adwaita-dark";
      #     # iconTheme = {
      #     #   package = pkgs.numix-icon-theme-square;
      #     #   name = "Numix-Square";
      #     # };
      #   };
      # };

      # Disabling xterm will let lightdm fall back on launching GNOME by
      # default. TODO figure out a better way to do this.
      desktopManager.xterm.enable = false;
      
      desktopManager.gnome3 = {
        enable = true;
        extraGSettingsOverrides =
          let workspaces = map toString (lib.lists.range 1 12);
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
