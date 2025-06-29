{ config, lib, pkgs, ... }:

# Enables S3 suspend state after upgrading the BIOS to at least version 1.33
# and setting standby to linux mode:
# https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Yoga_(Gen_3)#Enabling_S3_(with_BIOS_version_1.33_and_after)

{
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  services.logind.lidSwitch = lib.mkDefault "suspend-then-hibernate";
}
