{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    solvespace
    cura
  ];
}
