{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    # Equivalent of /etc/docker/daemon.json
    extraOptions = "--config-file=${pkgs.writeText "daemon.json" (builtins.toJSON {
      # Fix for route conflicts with VPNs, which typically operate in the
      # 172.16.0.0/12 space
      bip = "192.168.253.0/23";
      default-address-pools = [{
        base = "192.168.254.0/23";
        size = 27;
      }];
    })}";
  };

  users.users = {
    josh = {
      extraGroups = [ "docker" ];
    };
  };
}
