{ config, pkgs, ... }:

let
  version = "0.8.0";
  sources = {
    "x86_64-linux" = pkgs.fetchurl {
      url = "https://github.com/crmne/spotifast/releases/download/v${version}/spotifast-v${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "279caf363897e165a9f95c03a34313a8afa16128032eba3bf6b2cb88723394a4";
    };
    "aarch64-linux" = pkgs.fetchurl {
      url = "https://github.com/crmne/spotifast/releases/download/v${version}/spotifast-v${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "a09e4b11a96f0a36dc4ba66a7ef5c4238741acd270f9124a97f70ccab116e359";
    };
  };
  runtimeLibraries = with pkgs; [
    alsa-lib
    dbus
    fontconfig
    freetype
    libGL
    libpulseaudio
    libX11
    libXcursor
    libXi
    libXrandr
    libxkbcommon
    wayland
  ];
  spotifast =
    assert pkgs.lib.assertOneOf "stdenv.hostPlatform.system" pkgs.stdenv.hostPlatform.system (builtins.attrNames sources);
    pkgs.stdenv.mkDerivation {
      pname = "spotifast";
      inherit version;
      src = sources.${pkgs.stdenv.hostPlatform.system};

      nativeBuildInputs = with pkgs; [
        autoPatchelfHook
        makeWrapper
      ];
      buildInputs = runtimeLibraries;

      installPhase = ''
        runHook preInstall
        install -Dm755 spotifast $out/bin/spotifast
        install -Dm755 fastpotify $out/bin/fastpotify
        install -Dm644 LICENSE $out/share/licenses/spotifast/LICENSE
        install -Dm644 README.md $out/share/doc/spotifast/README.md
        install -Dm644 packaging/applications/fastpotify.desktop \
          $out/share/applications/fastpotify.desktop
        install -Dm644 packaging/icons/fastpotify.svg \
          $out/share/icons/hicolor/scalable/apps/fastpotify.svg
        runHook postInstall
      '';

      postFixup = ''
        wrapProgram $out/bin/spotifast \
          --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeLibraries}
        wrapProgram $out/bin/fastpotify \
          --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeLibraries}
      '';

      meta = {
        description = "A fast, native Spotify client";
        homepage = "https://spotifast.rocks";
        license = pkgs.lib.licenses.mit;
        mainProgram = "spotifast";
        platforms = builtins.attrNames sources;
      };
    };
in
{
  environment.systemPackages = [ spotifast ];
}
