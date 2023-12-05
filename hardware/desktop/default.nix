{ config, pkgs, ... }:

{
  # Merge luks options for better SSD performance.
  boot.initrd.luks.devices."root" = {
    bypassWorkqueues = true;
    allowDiscards = true;
  };
  services.fstrim.enable = true;

  hardware.bluetooth.enable = false;

  # NVIDIA drivers
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true; # needed for docker nvidia
    extraPackages = with pkgs; [ vaapiVdpau ]; # accelerated video playback
  };
  virtualisation.docker.enableNvidia = true;

  # NVIDIA drivers don't play nice with Wayland yet.
  services.xserver.displayManager.gdm.wayland = false;

  environment.systemPackages = with pkgs; [ nvtop ];
}
