{ config, pkgs, ... }:
let
  listenPort = 51820;
  interfaceName = "wg0";
in
{
  networking = {
    wireguard = {
      enable = true;
      interfaces = {
        "${interfaceName}" = {
          privateKeyFile = "/opt/wireguard/private-key";
          listenPort = listenPort;
          ips = [
            "172.31.0.1/24"
            "fd42::1/64"
          ];
          peers = [
            {
              # isobit-x1 laptop
              publicKey = "nWe8fml9B2Bx+1ajha9FgaUCTEVU2P7oCTbGbapDgx0=";
              allowedIPs = [
                "172.31.0.2/32"
                "fd42::2/128"
              ];
            }
          ];
        };
      };
    };
    firewall = {
      allowedUDPPorts = [listenPort];
      trustedInterfaces = [interfaceName];
    };
    nat = {
      enable = true;
      internalInterfaces = [interfaceName];
      externalInterface = "enp1s0";
    };
  };
}
