{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "josh";
    dataDir = "/home/josh/.config/syncthing";
  };
}
