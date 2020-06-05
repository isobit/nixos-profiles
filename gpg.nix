{ config, lib, pkgs, ... }:

{
  programs.gnupg.agent.enable = true;
  environment.systemPackages = (with pkgs; [
    gnupg
  ]);
}
