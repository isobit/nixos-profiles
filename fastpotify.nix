{ config, pkgs, ... }:

let
  version = "0.5.0";
  sources = {
    "x86_64-linux" = pkgs.fetchurl {
      url = "https://github.com/crmne/fastpotify/releases/download/v${version}/fastpotify-v${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "616f8203886aa93038c5ffd059b36836b6259af6e84b78951d25062395f96f6c";
    };
    "aarch64-linux" = pkgs.fetchurl {
      url = "https://github.com/crmne/fastpotify/releases/download/v${version}/fastpotify-v${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "8e2ffe30110eb3dd197f22181b98a8fe02f0334d7500c70a2a340b252dc49937";
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
  fastpotify =
    assert pkgs.lib.assertOneOf "stdenv.hostPlatform.system" pkgs.stdenv.hostPlatform.system (builtins.attrNames sources);
    pkgs.stdenv.mkDerivation {
      pname = "fastpotify";
      inherit version;
      src = sources.${pkgs.stdenv.hostPlatform.system};

      nativeBuildInputs = with pkgs; [
        autoPatchelfHook
        makeWrapper
      ];
      buildInputs = runtimeLibraries;

      installPhase = ''
        runHook preInstall
        install -Dm755 fastpotify $out/bin/fastpotify
        install -Dm644 LICENSE $out/share/licenses/fastpotify/LICENSE
        install -Dm644 README.md $out/share/doc/fastpotify/README.md
        install -Dm644 packaging/applications/fastpotify.desktop \
          $out/share/applications/fastpotify.desktop
        install -Dm644 packaging/icons/fastpotify.svg \
          $out/share/icons/hicolor/scalable/apps/fastpotify.svg
        runHook postInstall
      '';

      postFixup = ''
        wrapProgram $out/bin/fastpotify \
          --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeLibraries}
      '';

      meta = {
        description = "A fast, native Spotify client";
        homepage = "https://fastpotify.rocks";
        license = pkgs.lib.licenses.mit;
        mainProgram = "fastpotify";
        platforms = builtins.attrNames sources;
      };
    };
in
{
  environment.systemPackages = [ fastpotify ];
}
