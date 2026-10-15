{ config, pkgs, ... }:

let
  version = "0.13.3";
  sources = {
    "x86_64-linux" = pkgs.fetchurl {
      url = "https://github.com/crmne/spotifast/releases/download/v${version}/spotifast-v${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "3412306e41b2cae2f7554bf973e442cf5dcef1f69e4c24045f2317ce80d24970";
    };
    "aarch64-linux" = pkgs.fetchurl {
      url = "https://github.com/crmne/spotifast/releases/download/v${version}/spotifast-v${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "32b557445847167b56f203e84288c79ec885e58ed5167a9875b03da60d7d5c04";
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
        ln -s spotifast $out/bin/fastpotify
        install -Dm644 LICENSE $out/share/licenses/spotifast/LICENSE
        install -Dm644 README.md $out/share/doc/spotifast/README.md
        install -Dm644 spotifast-portable.txt $out/share/doc/spotifast/spotifast-portable.txt
        install -Dm644 packaging/applications/spotifast.desktop \
          $out/share/applications/spotifast.desktop
        install -Dm644 packaging/icons/spotifast.svg \
          $out/share/icons/hicolor/scalable/apps/spotifast.svg
        install -Dm644 contrib/omarchy/spotifast.json.tpl \
          $out/share/spotifast/omarchy/spotifast.json.tpl
        install -Dm755 contrib/omarchy/spotifast-theme \
          $out/share/spotifast/omarchy/spotifast-theme
        runHook postInstall
      '';

      postFixup = ''
        wrapProgram $out/bin/spotifast \
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
