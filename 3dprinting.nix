{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # CAD
    solvespace
    freecad

    # Slicers
    # cura
    prusa-slicer
  ];
}
