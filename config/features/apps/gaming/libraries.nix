{
  lib,
  pkgs,
  ...
}:
{
  # For standalone, unpatched Linux binaries. Steam and Heroic provide their own
  # runtime environments; Steam-specific additions belong in extraLibraries.
  # nix-ld already supplies common libraries such as the C++ runtime, zlib,
  # OpenSSL, libxml2, bzip2, and systemd. Commands and data files belong elsewhere.
  programs.nix-ld.libraries = with pkgs; [
    # electron based launchers need newer versions of these libraries than what runtime provides
    sqlite
    # Blender
    libdecor
    # Godot Engine
    libunwind
    # Others
    libXcomposite
    libXtst
    libXrandr
    libXext
    libX11
    libXfixes
    libxkbfile
    libGL
    libva
    alsa-lib
    libpulseaudio
    # Launcher UI libraries
    harfbuzz
    libthai
    pango
    brotli
    fuse3
    libnotify
    pipewire
    x264
    libplist

    # Graphics libraries for standalone games
    mesa
    mesa.llvmPackages.llvm.lib
    vulkan-loader
    expat
    wayland
    libxcb
    libXdamage
    libxshmfence
    libXxf86vm
    libelf
    (lib.getLib elfutils)

    # Without these it silently fails
    libXinerama
    libXcursor
    libXrender
    libXScrnSaver
    libXi
    libSM
    libICE
    curlWithGnuTls
    nspr
    nss
    cups
    libcap
    libusb1
    dbus
    dbus-glib
    ffmpeg
    libudev0-shim

    # Verified games requirements
    fontconfig
    freetype
    libXt
    libXmu
    libogg
    libvorbis
    glew_1_10
    libidn
    tbb

    # Other things from runtime
    glib
    gtk3
    flac
    freeglut
    libjpeg
    libpng
    libsamplerate
    libmikmod
    libtheora
    libtiff
    pixman
    speex
    libappindicator-gtk3
    libcaca
    libcanberra
    libgcrypt
    libvpx
    librsvg
    libXft
    libvdpau

    # Not formally in runtime but needed by some games
    at-spi2-core # CrossCode
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-base
    json-glib # paradox launcher (Stellaris)
    libxkbcommon # paradox launcher
    libxcrypt # Alien Isolation, XCOM 2, Company of Heroes 2
    mono
    libpciaccess
    icu # dotnet runtime, e.g. Stardew Valley

    # screeps dependencies
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
