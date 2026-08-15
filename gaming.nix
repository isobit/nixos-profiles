{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
  programs.gamemode.enable = true;
  hardware.xone.enable = true; # xbox controller support

  environment.systemPackages = with pkgs; [
    prismlauncher # minecraft
  ];
}
