{ config, pkgs, ... }:

let
  # Standalone, independently-runnable Python daemon. All parsing/math happen
  # in-process; only `amixer` and `alsactl monitor` (both alsa-utils) are
  # spawned, so alsa-utils is placed on PATH via makeWrapper. The same binary
  # works from the CLI and from the systemd user service below. Run
  # `ga403-speaker-volume-sync --show` or `--dry-run` to test without changing
  # the mixer.
  #
  # The daemon monitors ALSA controls directly (alsactl monitor), so it does
  # not depend on PipeWire at runtime; the pipewire ordering below only ensures
  # the sound stack has settled before we first reconcile the amps.
  runtimeDeps = with pkgs; [ alsa-utils ];
  volumeSync = pkgs.runCommand "ga403-speaker-volume-sync"
    {
      nativeBuildInputs = [ pkgs.makeWrapper pkgs.python3 ];
    }
    ''
      install -Dm755 ${./ga403-speaker-volume-sync.py} \
        "$out/bin/ga403-speaker-volume-sync"
      patchShebangs "$out/bin/ga403-speaker-volume-sync"
      wrapProgram "$out/bin/ga403-speaker-volume-sync" \
        --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
    '';
in
{
  # Make the script available for manual testing:
  #   ga403-speaker-volume-sync --show
  #   ga403-speaker-volume-sync --dry-run
  #   ga403-speaker-volume-sync --once
  environment.systemPackages = [ volumeSync ];

  systemd.user.services.ga403-speaker-volume-sync = {
    description = "Synchronize GA403UP CS35L56 woofer volume with Master";

    wantedBy = [ "default.target" ];

    after = [
      "pipewire.service"
      "pipewire-pulse.service"
      "wireplumber.service"
    ];

    partOf = [
      "pipewire.service"
      "pipewire-pulse.service"
      "wireplumber.service"
    ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${volumeSync}/bin/ga403-speaker-volume-sync";
      Restart = "always";
      RestartSec = "2s";
    };
  };
}
