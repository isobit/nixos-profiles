{ config, lib, pkgs, ... }:

{
  # Larger console font
  i18n.consoleFont = lib.mkDefault "latarcyrheb-sun32";

  # Also use large console font in initrd
  boot.earlyVconsoleSetup = true;

  # Try use maximum resolution in systemd-boot
  boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";

  # services.xserver.dpi = 210;
  # fonts.fontconfig.dpi = 210;
  # environment.variables = {
  #   GDK_SCALE = "2";
  #   GDK_DPI_SCALE = "0.5";
  # };
}
