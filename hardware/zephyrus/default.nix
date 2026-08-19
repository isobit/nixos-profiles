{ config, pkgs, ... }:

{
  imports = [
    ./audio.nix
  ];

  # Merge luks options for better SSD performance.
  # boot.initrd.luks.devices."root" = {
  #   bypassWorkqueues = true;
  #   allowDiscards = true;
  # };
  # services.fstrim.enable = true;

  # NVIDIA drivers with offloading to AMD integrated graphics
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];
  nixpkgs.config.allowUnfree = true;
  hardware.nvidia = {
    # Rolling back driver due to issues with 595.
    branch = "legacy_580";

    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # provides `nvidia-offload`
      };

      nvidiaBusId = "PCI:1@0:0:0";
      amdgpuBusId = "PCI:101@0:0:0";
    };
  };

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";

  services.asusd.enable = true;
  # Ensure /etc/asusd exists before the packaged asusd unit's
  # sandbox/mount namespace is set up.
  environment.etc."asusd/.keep".text = "";

  environment.systemPackages = with pkgs; [ nvtopPackages.full ];
}
