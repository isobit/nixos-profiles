{ config, pkgs, ... }:
let
  dataDir = "/opt/minecraft";
  stdinFIFO = "/run/minecraft.stdin";
in {
  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
    home = dataDir;
    # createHome = true;
  };
  users.groups.minecraft = {};
  users.users.josh.extraGroups = [ "minecraft" ];

  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 25565 ];
  };

  systemd.sockets.minecraft = {
    bindsTo = [ "minecraft.service" ];
    socketConfig = {
      ListenFIFO = stdinFIFO;
      SocketMode = "0660";
      SocketUser = "minecraft";
      SocketGroup = "minecraft";
      RemoveOnStop = true;
      FlushPending = true;
    };
  };

  systemd.services.minecraft = {
    description = "Minecraft Server";
    wantedBy = [ "multi-user.target" ];
    requires = [ "minecraft.socket" ];
    wants = ["network-online.target"];
    after = ["network-online.target" "minecraft.socket" ];
    serviceConfig = {
      ExecStart = "${pkgs.jdk}/bin/java -server -Xms512M -Xmx4096M -jar server.jar nogui";
      ExecStop = pkgs.writeShellScript "minecraft-server-stop" ''
        echo stop > ${stdinFIFO}
        # Wait for the PID of the minecraft server to disappear before
        # returning, so systemd doesn't attempt to SIGKILL it.
        while kill -0 "$MAINPID" 2> /dev/null; do
          sleep 1s
        done
      '';

      Restart = "always";
      User = "minecraft";
      WorkingDirectory = dataDir;

      StandardInput = "socket";
      StandardOutput = "journal";
      StandardError = "journal";

      # Hardening
      CapabilityBoundingSet = [ "" ];
      DeviceAllow = [ "" ];
      LockPersonality = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "0077";
    };
  };
}
