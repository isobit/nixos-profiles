{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ platformio ];
  services.udev.packages = with pkgs; [ platformio-core.udev openocd ];
  users.users.josh.extraGroups = [ "dialout" ];
  # networking.firewall = {
  #   allowedTCPPorts = [ 8266 ];
  #   allowedUDPPorts = [ 8266 ];
  # };
}
