{ config, lib, pkgs, ... }:

{
  # Requires github.com/NixOS/nixos-hardware channel
  imports = [
    <nixos-hardware/lenovo/thinkpad/x1/yoga>
  ];
}
