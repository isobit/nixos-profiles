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
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
  };

  environment.systemPackages = with pkgs; [ nvtopPackages.full ];
}
