# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./profiles/default.nix
    # TODO Put additional profiles here
    ./hardware-configuration.nix
  ];

  # Encrypted disk with LUKS
  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/<UUID-HERE>"; # TODO
      preLVM = true;
    }
  ];

  networking = {
    hostName = "<HOSTNAME>"; # TODO
    # Set firewall rules here, for example:
    # firewall = {
    #   allowedTCPPorts = [ 22 80 ];
    #   allowedTCPPortRanges = [ { from = 8999; to = 9003; } ];
    #   allowedUDPPorts = [ 53 ];
    #   allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
    # }
    # Don't forget that some services have options to automatically open ports
    # so they may not have to be defined here.
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
}
