{ config, pkgs, ... }:

{
  # Requires github.com/NixOS/nixos-hardware channel
  imports = [
    <nixos-hardware/common/cpu/amd>
    <nixos-hardware/common/gpu/nvidia>
    <nixos-hardware/common/pc/ssd>
  ];
}
