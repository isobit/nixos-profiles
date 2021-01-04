{ config, lib, pkgs, ... }:

# S3 sleep is not supported out of the box so a few steps are taken here to
# mitigate the downsides of S2idle sleep mode.
# See the following for more info:
# https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Yoga_(Gen_3)#Enabling_S2idle
# https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)#Suspend_issues

{
  # Reduces power consumption of S2idle sleep mode
  boot.kernelParams = [ "acpi.ec_no_wakeup=1" ];

  services.logind = {
    # Default the lid close action to hibernate
    lidSwitch = lib.mkDefault "hibernate";

    # Always hibernate when lid is closed, regardless of sleep state
    extraConfig = lib.mkDefault "LidSwitchIgnoreInhibited=yes";
  };
}
