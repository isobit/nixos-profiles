{ config, pkgs, ... }:

{
  boot.extraModulePackages = [
    config.boot.kernelPackages.wireguard
  ];
  environment.systemPackages = with pkgs; [
    wireguard
    wireguard-tools
  ];
}
