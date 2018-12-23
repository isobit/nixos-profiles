{ config, lib, pkgs, ... }:

{
  # Requires github.com/NixOS/nixos-hardware channel
  imports = [
    <nixos-hardware/lenovo/thinkpad>
    <nixos-hardware/lenovo/thinkpad/acpi_call.nix>
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/pc/ssd>
  ];

  # This should be covered by <nixos-hardware/lenovo/thinkpad/acpi_call.nix>
  # boot.extraModulePackages = [ pkgs.linuxPackages.acpi_call ];
  # services.tlp.enable = true;

  # Enable Synaptics RMI so that Touchpad and TrackPoint both work
  boot.kernelParams = [ "psmouse.synaptics_intertouch=1" ];

  boot.kernelModules = [ "thinkpad_acpi" ];

  services = {

    acpid.enable = true;

    thinkfan = {
      enable = lib.mkDefault true;
      sensors = lib.mkDefault ''
        hwmon /sys/devices/virtual/hwmon/hwmon0/temp1_input
      '';
    };

    xserver = {
      multitouch.enable = lib.mkDefault true;
      wacom.enable = lib.mkDefault true;

      # Fix visual tearing in some full-screen applications (e.g. GNOME Videos)
      deviceSection = ''
        Option "AccelMethod" "sna"
        Option "TearFree" "true"
      '';
    };

    # This would enable the fingerprint reader, but it appears the X1 Yoga
    # 3rd Gen's specific hardware is not supported yet.
    # See https://forums.lenovo.com/t5/Linux-Discussion/X1C-gen-6-Fibocom-L850-GL-Ubuntu-18-04/m-p/4078413
    #
    # fprintd.enable = true;

  };

  # Boot with bluetooth disabled
  hardware.bluetooth.powerOnBoot = false;

  # Enable bluetooth audio
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  systemd.services.thinkpad-x1y3-cpu-throttling-fix = {
    enable = true;
    description = "ThinkPad X1Y3 CPU Throttling Fix";
    documentation = [
      "https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)#Power_management.2FThrottling_issues"
    ];
    wantedBy = [ "timers.target" ];
    serviceConfig = { Type = "oneshot"; };
    path = [ pkgs.msr-tools ];
    script = ''
      # Sets the offset to 3 °C, so the new trip point is 97 °C
      wrmsr -a 0x1a2 0x3000000
    '';
  };

  systemd.timers.thinkpad-x1y3-cpu-throttling-fix = {
    enable = true;
    description = "ThinkPad X1Y3 CPU Throttling Fix";
    documentation = [
      "https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)#Power_management.2FThrottling_issues"
    ];
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnActiveSec = 60;
      OnUnitActiveSec = 60;
      Unit = "thinkpad-x1y3-cpu-throttling-fix.service";
    };
  };

}
