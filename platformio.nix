{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ platformio ];
  services.udev.packages = with pkgs; [ platformio-core.udev openocd ];
  users.users.josh.extraGroups = [
    "dialout"
    "plugdev" # not strictly necessary but avoids error logs in journal
  ];
  # networking.firewall = {
  #   allowedTCPPorts = [ 8266 ];
  #   allowedUDPPorts = [ 8266 ];
  # };
}
