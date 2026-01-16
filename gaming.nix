{ pkgs, ... }:
{
  programs.steam.enable = true;
  hardware.xone.enable = true; # xbox controller support
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    prismlauncher # minecraft
  ];

  # Attempt to fix audio issues
  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 512;  # Start here and increase if needed
      "default.clock.min-quantum" = 512;
      "default.clock.max-quantum" = 2048;
    };
  };
}
