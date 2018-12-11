{ config, lib, pkgs, ... }:

# S3 sleep is not supported out of the box so a few steps are taken here to
# mitigate, mainly reducing the power consumption of S0i3 sleep mode and
# defaulting the lid close action to hibernate.
# See the following for more info:
# https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)#Suspend_issues

{

  # Reduces power consumption of S0i3 sleep mode, see the following for
  # more info and additional power saving tips:
  # https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)#S0i3_sleep_support
  boot.kernelParams = [ "acpi.ec_no_wakeup=1" ];

  services.logind = {
    # Mitigate high S0i3 sleep mode power consumption by defaulting the lid
    # close action to hibernate
    lidSwitch = lib.mkDefault "hibernate";

    # Always hibernate when lid is closed, regardless of sleep state
    extraConfig = lib.mkDefault "LidSwitchIgnoreInhibited=yes";
  };

}
