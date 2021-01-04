{ config, pkgs, ... }:

{
  boot.blacklistedKernelModules = [
    "sp5100_tco" # kernel logs "sp5100-tco sp5100-tco: Watchdog hardware is disabled" if this is on
  ];

  # nvidia
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.gdm.wayland = false; # Wayland not very compatible with nvidia

  # GDM monitors.xml, keeps login page off TV HDMI
  # Use https://github.com/NixOS/nixpkgs/pull/107850 instead once merged
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${pkgs.writeText "gdm-monitors.xml" ''
      <monitors version="2">
        <configuration>
          <logicalmonitor>
            <x>0</x>
            <y>0</y>
            <scale>1</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>DP-0</connector>
                <vendor>SAM</vendor>
                <product>C32JG5x</product>
                <serial>HTHM600038</serial>
              </monitorspec>
              <mode>
                <width>2560</width>
                <height>1440</height>
                <rate>143.99830627441406</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <disabled>
            <monitorspec>
              <connector>HDMI-0</connector>
              <vendor>TCL</vendor>
              <product>TCL</product>
              <serial>0x01010101</serial>
            </monitorspec>
          </disabled>
        </configuration>
      </monitors>
    ''}"
  ];
}
