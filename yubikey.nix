{ config, lib, pkgs, ... }:

{
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  environment.systemPackages = (with pkgs; [
    yubikey-personalization
  ] ++ lib.optionals (config.services.xserver.enable) [
    yubikey-personalization-gui
  ]);
}
