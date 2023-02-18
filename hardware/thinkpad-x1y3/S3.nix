{ config, lib, pkgs, ... }:

# Enables S3 suspend state after upgrading the BIOS to at least version 1.33
# and setting standby to linux mode:
# https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Yoga_(Gen_3)#Enabling_S3_(with_BIOS_version_1.33_and_after)

{
  boot.kernelParams = [ "mem_sleep_default=deep" ];

  services.logind.lidSwitch = lib.mkDefault "suspend";

  # # Automatically fixes some issue that arise when resuming from sleep
  # systemd.services.thinkpad-x1y3-s3-resume-fix = {
  #   enable = true;
  #   description = "ThinkPad X1Y3 S3 Resume Fix";
  #   documentation = [
  #     "https://forums.lenovo.com/t5/Linux-Discussion/X1Y3-Touchscreen-not-working-after-resume-on-Linux/m-p/4149363/highlight/true#M11427"
  #   ];
  #   wantedBy = [ "suspend.target" ];
  #   after = [ "suspend.target" ];
  #   serviceConfig = { Type = "oneshot"; };
  #   path = [ pkgs.utillinux pkgs.kmod ];
  #   script = ''
  #     sleep 1

  #     # Fix touchscreen
  #     rtcwake -m freeze -s 1

  #     # Fix touchpad
  #     modprobe -r psmouse
  #     modprobe psmouse
  #   '';
  # };
}
