{ lib, stdenv, fetchzip, unzip, makeWrapper, patchelf, gtk3, glib, xorg, libGL, vulkan-loader, electron, ffmpeg, nss, nspr, dbus, atk, cups, pango, cairo, mesa, libdrm, libgbm, expat, libxkbcommon, systemd, alsa-lib, ... }:

stdenv.mkDerivation rec {
  pname = "edhm-ui-v3";
  version = "3.0.60";

  src = fetchzip {
    url = "https://github.com/BlueMystical/EDHM_UI/releases/download/v${version}/edhm-ui-v3-linux-x64.zip";
    sha256 = "sha256-v4510IIUJ/ALBw1Y1694NRBEanDSeihNnCHCRljPRbo=";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper unzip patchelf ];

  buildInputs = [
    gtk3
    glib
    xorg.libX11
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXi
    xorg.libXxf86vm
    xorg.libXtst
    xorg.libXScrnSaver
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    libGL
    vulkan-loader
    stdenv.cc.cc.lib
    ffmpeg
    nss
    nspr
    dbus
    atk
    cups
    pango
    cairo
    mesa
    libdrm
    libgbm
    expat
    libxkbcommon
    systemd
    alsa-lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/EDHM-UI-V3
    mkdir -p $out/share/applications
    mkdir -p $out/share/pixmaps

    cp -r edhm-ui-v3-linux-x64/* $out/share/EDHM-UI-V3/
    chmod +x $out/share/EDHM-UI-V3/edhm-ui-v3

    if [ -f $out/share/EDHM-UI-V3/resources/images/icon.png ]; then
      cp $out/share/EDHM-UI-V3/resources/images/icon.png $out/share/pixmaps/edhm-ui-v3.png
    fi

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${lib.makeLibraryPath buildInputs}" \
      $out/share/EDHM-UI-V3/edhm-ui-v3

    makeWrapper $out/share/EDHM-UI-V3/edhm-ui-v3 $out/bin/edhm-ui-v3 \
      --prefix LD_LIBRARY_PATH : "$out/share/EDHM-UI-V3:${lib.makeLibraryPath buildInputs}"

    cat > $out/share/applications/edhm-ui-v3.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
Name=EDHM-UI-V3
Exec=$out/bin/edhm-ui-v3
Icon=edhm-ui-v3
Terminal=false
Type=Application
Comment=Mod for Elite Dangerous to customize the HUD of any ship.
StartupNotify=true
Categories=Utility;Game;
EOF

    runHook postInstall
  '';

  meta = with lib; {
    description = "Elite Dangerous HUD Mod - UI for customizing ship HUD";
    homepage = "https://github.com/BlueMystical/EDHM_UI";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
