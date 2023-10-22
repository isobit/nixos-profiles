{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.cloudflare-ddns;
in {
  options.services.cloudflare-ddns = {
    enable = mkEnableOption "cloudflare-ddns";
    onCalendar = mkOption {
      type = types.str;
      default = "hourly";
    };
    apiToken = mkOption {
      type = types.str;
    };
    zoneId = mkOption {
      type = types.str;
    };
    ARecordIds = mkOption {
      type = with types; listOf str;
      default = [];
    };
    AAAARecordIds = mkOption {
      type = with types; listOf str;
      default = [];
    };
  };
  config = mkIf cfg.enable {
    systemd.services.cloudflare-ddns = {
      description = "Cloudflare DDNS";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        CLOUDFLARE_API_TOKEN = cfg.apiToken;
        CLOUDFLARE_ZONE_ID = cfg.zoneId;
        CLOUDFLARE_A_RECORD_IDS = strings.concatStringsSep " " cfg.ARecordIds;
        CLOUDFLARE_AAAA_RECORD_IDS = strings.concatStringsSep " " cfg.AAAARecordIds;
      };
      path = with pkgs; [ curl ];
      script = builtins.readFile ./cloudflare-ddns.sh;
    };

    systemd.timers.cloudflare-ddns = {
      description = "Cloudflare DDNS";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.onCalendar;
        Unit = "cloudflare-ddns.service";
      };
    };
  };
}
