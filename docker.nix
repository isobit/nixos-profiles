{ config, lib, pkgs, ... }:

let
  buildkit = true;
in
{
  virtualisation.docker = {
    enable = true;
    # Use socket activation by default, override in configuration.nix if
    # desired.
    enableOnBoot = lib.mkDefault false;
    # Equivalent of /etc/docker/daemon.json
    extraOptions = "--config-file=${pkgs.writeText "daemon.json" (builtins.toJSON {
      features = {
        buildkit = buildkit;
      };

      # Fix for route conflicts with VPNs, which typically operate in the
      # 172.16.0.0/12 space.
      bip = "192.168.253.0/23";
      default-address-pools = [{
        base = "192.168.254.0/23";
        size = 27;
      }];
    })}";
  };

  users.users = {
    # Add users to docker group to use docker without sudo
    josh = {
      extraGroups = [ "docker" ];
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  environment.variables.COMPOSE_DOCKER_CLI_BUILD = lib.mkIf buildkit "1";
}
