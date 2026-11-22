{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    flameshot
    gnomeExtensions.appindicator
  ];
  services.dbus.packages = with pkgs; [ flameshot ];

  # Bind Print to flameshot. GNOME's own screenshot UI claims Print by
  # default, so move it to Shift+Super+S to avoid the conflict.
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/shell/keybindings".show-screenshot-ui = [ "<Shift><Super>s" ];
        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-flameshot/"
        ];
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-flameshot" = {
          name = "flameshot";
          command = "flameshot gui";
          binding = "Print";
        };
      };
    }
  ];
}
