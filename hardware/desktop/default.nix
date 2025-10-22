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
  hardware.nvidia.open = false;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.package =
    with import <nixos-unstable> { config = { allowUnfree = true; }; };
    linuxPackages.nvidiaPackages.latest;

  environment.systemPackages = with pkgs; [ nvtopPackages.full ];
}
