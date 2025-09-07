{
  lib,
  pkgs,
  ...
}:
{
  programs.nix-ld.libraries = with pkgs; [
    # Needed for operating system detection until
    # https://github.com/ValveSoftware/steam-for-linux/issues/5909 is resolved
    lsb-release
    # Errors in output without those
    pciutils
    # Games' dependencies
    xorg.xrandr
    which
    # Needed by gdialog, including in the steam-runtime
    perl
    # Open URLs
    xdg-utils
    iana-etc
    # Steam Play / Proton
    python3

    # It tries to execute xdg-user-dir and spams the log with command not founds
    xdg-user-dirs

    # electron based launchers need newer versions of these libraries than what runtime provides
    sqlite
    # Godot + Blender
    stdenv.cc.cc
    # Blender
    libdecor
    # Godot Engine
    libunwind
    # Others
    xorg.libXcomposite
    xorg.libXtst
    xorg.libXrandr
    xorg.libXext
    xorg.libX11
    xorg.libXfixes
    xorg.libxkbfile
    libGL
    libva
    libva-utils
    #pipewire.lib
    ocamlPackages.alsa
    alsa-lib
    libpulseaudio
    # steamwebhelper
    harfbuzz
    libthai
    pango
    brotli
    fuse3
    icu
    libglvnd
    libnotify
    libxml2
    openssl
    pipewire
    pulseaudio
    systemd
    x264
    libplist

    lsof # friends options won't display "Launch Game" without it
    file # called by steam's setup.sh

    # dependencies for mesa drivers, needed inside pressure-vessel
    mesa
    mesa.llvmPackages.llvm.lib
    vulkan-loader
    expat
    wayland
    xorg.libxcb
    xorg.libXdamage
    xorg.libxshmfence
    xorg.libXxf86vm
    libelf
    (lib.getLib elfutils)

    # Without these it silently fails
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXi
    xorg.libSM
    xorg.libICE
    curlWithGnuTls
    nspr
    nss
    cups
    libcap
    libusb1
    dbus
    dbus-glib
    gsettings-desktop-schemas
    ffmpeg
    libudev0-shim

    # Verified games requirements
    fontconfig
    freetype
    xorg.libXt
    xorg.libXmu
    libogg
    libvorbis
    glew110
    libidn
    tbb
    zlib

    # SteamVR
    procps
    usbutils
    udev

    # Other things from runtime
    glib
    gtk2
    gtk3
    bzip2
    flac
    freeglut
    libjpeg
    libpng
    libpng12
    libsamplerate
    libmikmod
    libtheora
    libtiff
    pixman
    speex
    libappindicator-gtk2
    libappindicator-gtk3
    libdbusmenu-gtk2
    libindicator-gtk2
    libcaca
    libcanberra
    libgcrypt
    libvpx
    librsvg
    xorg.libXft
    libvdpau

    # required by coreutils stuff to run correctly
    # Steam ends up with LD_LIBRARY_PATH=<bunch of runtime stuff>:/usr/lib:<etc>
    # which overrides DT_RUNPATH in our binaries, so it tries to dynload the
    # very old versions of stuff from the runtime.
    attr

    # Not formally in runtime but needed by some games
    at-spi2-atk
    at-spi2-core # CrossCode
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-base
    json-glib # paradox launcher (Stellaris)
    libdrm
    libxkbcommon # paradox launcher
    libxcrypt # Alien Isolation, XCOM 2, Company of Heroes 2
    mono
    xorg.xkeyboardconfig
    xorg.libpciaccess
    icu # dotnet runtime, e.g. Stardew Valley

    # screeps dependencies
    atk
    cairo
    gdk-pixbuf

    # Prison Architect
    libGLU
    libuuid
    libbsd

    # Loop Hero
    libidn2
    libpsl
    nghttp2.lib
    rtmpdump
  ];
}
