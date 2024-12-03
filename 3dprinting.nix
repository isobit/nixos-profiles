{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    solvespace
    # cura # TODO broken package in nixos 24.11?
  ];
}
