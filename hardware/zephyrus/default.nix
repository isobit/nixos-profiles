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

  # GNOME doesn't seem to respect the toggle for "Dim Screen" in Power
  # Saving mode; dims after 30s even when disabled. As a workaround, we
  # can set the idle-brightness to 100 so it has no effect (actual
  # brighness will be min of idle-brightness and non-idle brightness).
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.settings-daemon.plugins.power]
    idle-brightness=100
  '';

  services.asusd.enable = true;
  # Ensure /etc/asusd exists before the packaged asusd unit's
  # sandbox/mount namespace is set up.
  environment.etc."asusd/.keep".text = "";

  # The keyboard's USB lighting controller can become unresponsive after
  # suspend-then-hibernate. Reauthorizing its USB device restores lighting,
  # and restarting UPower makes GNOME rediscover the replaced LED device.
  systemd.services.asus-keyboard-resume = {
    wantedBy = [ "sleep.target" ];
    after = [ "sleep.target" ];
    wants = [ "upower.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
      ExecStart = pkgs.writeShellScript "asus-keyboard-resume" ''
        sleep 2
        echo 0 > /sys/bus/usb/devices/1-4/authorized
        sleep 0.5
        echo 1 > /sys/bus/usb/devices/1-4/authorized
        sleep 0.5
        ${pkgs.systemd}/bin/systemctl restart upower.service
      '';
    };
  };

  environment.systemPackages = with pkgs; [ nvtopPackages.full ];
}
