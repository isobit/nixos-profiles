{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    flameshot
    gnomeExtensions.appindicator
  ];
  services.dbus.packages = with pkgs; [ flameshot ];
}
