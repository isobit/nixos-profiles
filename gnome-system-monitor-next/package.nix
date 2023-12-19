{ lib, stdenv, substituteAll, fetchFromGitHub, fetchpatch, glib, glib-networking, libgtop, gnome }:
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-system-monitor-next";
  version = "3.9";

  src = fetchFromGitHub {
    owner = "mgalgs";
    repo = "gnome-shell-system-monitor-applet";
    rev = "c19ea72139eeff15a5efb8c8648a8894a1ae3a8b";
    hash = "sha256-1ryhAA6xckNGWtAM05pxZymZqqMEvvw/PYRYNj6/Pio=";
  };

  nativeBuildInputs = [
    glib
    gnome.gnome-shell
  ];

  patches = [
    (substituteAll {
      src = ./paths_and_nonexisting_dirs.patch;
      gtop_path = "${libgtop}/lib/girepository-1.0";
      glib_net_path = "${glib-networking}/lib/girepository-1.0";
    })
  ];

  makeFlags = [
    "VERSION=${version}"
    "INSTALLBASE=$(out)/share/gnome-shell/extensions"
    "SUDO="
  ];

  passthru = {
    extensionUuid = "system-monitor-next@paradoxxx.zero.gmail.com";
    extensionPortalSlug = "system-monitor-next";
  };

  # meta = with lib; {
  #   description = "Display system informations in gnome shell status bar";
  #   license = licenses.gpl3Plus;
  #   maintainers = with maintainers; [ andersk ];
  #   homepage = "https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet";
  # };
}
