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
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Use better performing proprietary NVIDIA driver
  nixpkgs.config.allowUnfree = true;
  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    modesetting.enable = true;

    # Possible fix for glitches on suspend/resume
    # https://wiki.nixos.org/wiki/NVIDIA#Graphical_corruption_and_system_crashes_on_suspend/resume
    powerManagement.enable = true;
  };

  environment.systemPackages = with pkgs; [ nvtopPackages.full ];
}
