{ config, lib, pkgs, ... }:

{

  # Windows wants hardware clock in local time instead of UTC
  time.hardwareClockInLocalTime = true;

}
