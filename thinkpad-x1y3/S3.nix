{ config, lib, pkgs, ... }:

# Enables S3 suspend state after patching the ACPI DSDT table using the
# following instructions: https://delta-xi.net/#056

{

  # TODO: Build as part of package or something
  boot.initrd.prepend = [ "/boot/acpi_s3_fix" ];

  boot.kernelParams = [ "mem_sleep_default=deep" ];

  services.logind.lidSwitch = lib.mkDefault "suspend";

  systemd.services.thinkpad-x1y3-s3-resume-fix = {
    enable = true;
    description = "ThinkPad X1Y3 S3 Resume Fix";
    documentation = [
      "https://forums.lenovo.com/t5/Linux-Discussion/X1Y3-Touchscreen-not-working-after-resume-on-Linux/m-p/4149363/highlight/true#M11427"
    ];
    wantedBy = [ "suspend.target" ];
    after = [ "suspend.target" ];
    serviceConfig = { Type = "oneshot"; };
    path = [ pkgs.utillinux pkgs.kmod ];
    script = ''
      sleep 1

      # Fix touchscreen
      rtcwake -m freeze -s 1

      # Fix touchpad
      modprobe -r psmouse
      modprobe psmouse
    '';
  };

}
