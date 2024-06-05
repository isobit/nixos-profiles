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

  # TODO this might be needed if wayland is turned back on?
  # hardware.nvidia = {
  #   # Modesetting is needed for most Wayland compositors
  #   modesetting.enable = true;
  # };

  environment.systemPackages = with pkgs; [ nvtopPackages.full ];
}
