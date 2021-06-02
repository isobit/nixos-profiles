{ config, lib, pkgs, ... }:

let
  pomo = with pkgs; stdenv.mkDerivation rec {
    name = "pomo";
    src = fetchurl {
      url = "https://github.com/kevinschoon/pomo/releases/download/0.7.1/pomo-0.7.1-linux-amd64";
      sha256 = "0mlsydga0jlgs117kk60cr2jfd2hilbjn0b9dj6lybxp7bv31hv6";
    };
    nativeBuildInputs = [ autoPatchelfHook ];
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/pomo
      chmod +x $out/bin/pomo
    '';
  };
in
{
  environment.systemPackages = [ pomo ];
}
