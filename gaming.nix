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

  users.users.gaming = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [ "networkmanager" ];
      packages = with pkgs; [
        prismlauncher # minecraft
      ];
  };
}
