{ config, lib, pkgs, ... }:

{
  # Requires github.com/NixOS/nixos-hardware channel
  imports = [
    <nixos-hardware/lenovo/thinkpad>
    <nixos-hardware/common/cpu/intel>
    ./cpu-throttling-fix.nix
  ];

  # TLP (power management)
  # TODO Some of this should be covered by <nixos-hardware/common/pc/laptop/acpi_call.nix>
  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = [ pkgs.linuxPackages.acpi_call ];
  # services.tlp.enable = true;
  # services.tlp.extraConfig = ''
  #   START_CHARGE_THRESH_BAT0=75
  #   STOP_CHARGE_THRESH_BAT0=80
  #   CPU_SCALING_GOVERNOR_ON_BAT=powersave
  #   ENERGY_PERF_POLICY_ON_BAT=powersave
  # '';
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    ENERGY_PERF_POLICY_ON_BAT = "powersave";
  };

  # Enable TrackPoint
  hardware.trackpoint.enable = true;

  # Enable Synaptics RMI so that Touchpad and TrackPoint both work
  boot.kernelParams = [ "psmouse.synaptics_intertouch=1" ];

  # Enable acpid to handle special keys, power/sleep/suspend button, notebook
  # lid close, etc.
  services.acpid.enable = true;

  # ThinkFan controls fans by watching temperature data
  # https://wiki.archlinux.org/index.php/Fan_speed_control#ThinkPad_laptops
  services.thinkfan = {
    enable = true;
    sensors = lib.mkDefault ''
      hwmon /sys/devices/virtual/thermal/thermal_zone9/temp (-5) # x86_pkg_temp
      hwmon /sys/devices/virtual/thermal/thermal_zone7/temp # pch_skylake
      hwmon /sys/devices/virtual/thermal/thermal_zone5/temp (5) # CHAG
      hwmon /sys/devices/virtual/thermal/thermal_zone8/temp (5) # iwlwifi
      hwmon /sys/devices/virtual/thermal/thermal_zone6/temp (10) # SSD0
    '';
    levels = lib.mkDefault ''
      (0, 0, 55)
      (1, 48, 60)
      (2, 50, 61)
      (3, 52, 63)
      (6, 56, 65)
      (7, 60, 85)
      (127, 80, 32767)
    '';
  };
  systemd.services.thinkfan.after = [ "acpid.service" ];

  services.xserver = {
    # TODO figure out replacement for multitouch since it was deprecated in
    # NixOS 20.03
    # multitouch.enable = lib.mkDefault true;
    wacom.enable = lib.mkDefault true;
    videoDrivers = [ "intel" ];
  };

  # TODO This would enable the fingerprint reader, but it appears the X1 Yoga
  # 3rd Gen's specific hardware is not supported yet.
  # See https://forums.lenovo.com/t5/Linux-Discussion/X1C-gen-6-Fibocom-L850-GL-Ubuntu-18-04/m-p/4078413
  # services.fprintd.enable = true;

  # Enable bluetooth audio
  hardware.pulseaudio.package = lib.mkDefault pkgs.pulseaudioFull;
}
