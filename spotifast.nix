{ config, pkgs, ... }:

let
  version = "0.17.1";
  sources = {
    "x86_64-linux" = pkgs.fetchurl {
      url = "https://github.com/crmne/spotifast/releases/download/v${version}/spotifast-v${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "651702d4f18bf9c338eff96137723c122e187fd48902af4be562dc9b064c4970";
    };
    "aarch64-linux" = pkgs.fetchurl {
      url = "https://github.com/crmne/spotifast/releases/download/v${version}/spotifast-v${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "09a15da624485f9a7b4949491cf5bbfb6b17aef48a11cf868a5478f4fc1e6ae9";
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
    pipewire
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
