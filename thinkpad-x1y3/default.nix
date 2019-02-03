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
  services.tlp.enable = true;
  services.tlp.extraConfig = ''
    START_CHARGE_THRESH_BAT0=75
    STOP_CHARGE_THRESH_BAT0=80
    CPU_SCALING_GOVERNOR_ON_BAT=powersave
    ENERGY_PERF_POLICY_ON_BAT=powersave
  '';

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
      hwmon /sys/devices/virtual/thermal/thermal_zone0/temp
    '';
  };

  services.xserver = {
    multitouch.enable = lib.mkDefault true;
    wacom.enable = lib.mkDefault true;

    # Fix visual tearing in some full-screen applications (e.g. GNOME Videos)
    deviceSection = ''
      Option "AccelMethod" "sna"
      Option "TearFree" "true"
    '';
  };

  # TODO This would enable the fingerprint reader, but it appears the X1 Yoga
  # 3rd Gen's specific hardware is not supported yet.
  # See https://forums.lenovo.com/t5/Linux-Discussion/X1C-gen-6-Fibocom-L850-GL-Ubuntu-18-04/m-p/4078413
  # services.fprintd.enable = true;

  # Enable bluetooth audio
  hardware.pulseaudio.package = lib.mkDefault pkgs.pulseaudioFull;
}
