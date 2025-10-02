{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = (with pkgs; [
    # Apps
    slack
    zoom-us

    # Development tools
    awscli2
    ssm-session-manager-plugin
    bash
    circleci-cli
    gitAndTools.gitFull
    gnumake
    postgresql
    mysql84
    ruby

    # Credential management
    aws-vault
  ]);

  # Tailscale
  services.tailscale.enable = true;

  # ClamAV
  # services.clamav = {
  #   daemon.enable = true;
  # };
}
