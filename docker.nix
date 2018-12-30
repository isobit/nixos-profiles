{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  users.users = {
    josh = {
      extraGroups = [ "docker" ];
    };
  };
}
