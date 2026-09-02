{ config, pkgs, ... }:

let
  version = "0.4.1";
  sources = {
    "x86_64-linux" = pkgs.fetchurl {
      url = "https://github.com/crmne/fastpotify/releases/download/v${version}/fastpotify-v${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "68062a16774defde41994d12a17841fb535ad28b4b621d874f047d04176de173";
    };
    "aarch64-linux" = pkgs.fetchurl {
      url = "https://github.com/crmne/fastpotify/releases/download/v${version}/fastpotify-v${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "a4408f427409308679fb2bc437e7ca46f29c0129ed8ce1fca6cc49ca6ec1206b";
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
