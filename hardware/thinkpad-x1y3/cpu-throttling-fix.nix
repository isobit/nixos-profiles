{ config, lib, pkgs, ... }:

{
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
