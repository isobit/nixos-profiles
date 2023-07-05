{ config, pkgs, ... }:

{
  # Merge luks options for better SSD performance.
  boot.initrd.luks.devices."root" = {
    bypassWorkqueues = true;
    allowDiscards = true;
  };
  services.fstrim.enable = true;

  # nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.extraPackages = with pkgs; [ vaapiVdpau ];
  virtualisation.docker.enableNvidia = true;
  environment.systemPackages = with pkgs; [ nvtop ];
}
