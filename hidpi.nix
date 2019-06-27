{ config, lib, pkgs, ... }:

{
  # Larger console font
  i18n.consoleFont = lib.mkDefault "latarcyrheb-sun32";

  # Also use large console font in initrd
  boot.earlyVconsoleSetup = true;

  # Try use maximum resolution in systemd-boot
  boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";

  services.xserver.displayManager.lightdm.greeters.gtk.extraConfig = "xft-dpi=221";
}
