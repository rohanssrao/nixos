{ config, pkgs, lib, ... }:
{

  options = {
    environment.lsb.enable = lib.mkOption {
      type = lib.types.bool;
      description = ''
        Enable approximate LSB binary compatibility. This allows
        binaries that run on other distros to run on NixOS.
      '';
      default = false;
    };

    environment.lsb.support32Bit = lib.mkOption {
      type = lib.types.bool;
      description = ''
        Enable LSB binary compatibility.
      '';
      default = false;
    };

  };

  config = let

    libsFromPkgs = pkgs:
      with pkgs;
      [
        # taken from Mic92/nix-ld + steam-run + balsoft/nixos-fhs-compat
        zstd
        stdenv.cc.cc
        libssh
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd

        xorg.libXcomposite
        xorg.libXtst
        xorg.libXrandr
        xorg.libXext
        xorg.libX11
        xorg.libXfixes
        libGL
        libva
        pipewire
        harfbuzz
        libthai
        pango
        lsof
        file
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
        xorg.libXinerama
        xorg.libXcursor
        xorg.libXrender
        xorg.libXScrnSaver
        xorg.libXi
        xorg.libSM
        xorg.libICE
        gnome2.GConf
        curlWithGnuTls
        nspr
        nss
        cups
        libcap
        SDL2
        libusb1
        dbus-glib
        gsettings-desktop-schemas
        ffmpeg
        libudev0-shim
        fontconfig
        freetype
        xorg.libXt
        xorg.libXmu
        libogg
        libvorbis
        SDL
        SDL2_image
        glew110
        libdrm
        libidn
        tbb
        zlib
        udev
        dbus
        glib
        gtk2
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
        SDL_image
        SDL_ttf
        SDL_mixer
        SDL2_ttf
        SDL2_mixer
        libappindicator-gtk2
        libdbusmenu-gtk2
        libindicator-gtk2
        libcaca
        libcanberra
        libgcrypt
        libunwind
        libvpx
        librsvg
        xorg.libXft
        libvdpau
        attr
        at-spi2-atk
        at-spi2-core
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-plugins-base
        json-glib
        libxkbcommon
        libxcrypt
        mono
        ncurses
        openssl
        xorg.xkeyboardconfig
        xorg.libpciaccess
        icu
        gtk3
        atk
        cairo
        gdk-pixbuf
        libGLU
        libuuid
        libbsd
        alsa-lib
        libidn2
        libpsl
        nghttp2.lib
        rtmpdump

        libgpg-error
        libpulseaudio
        openalSoft
        libva1
        gcc.cc.lib

        glibc
        linux-pam
        sane-backends
      ];

    base-libs32 = pkgs.buildEnv {
      name = "fhs-base-libs32";
      paths = map lib.getLib (libsFromPkgs pkgs.pkgsi686Linux);
      extraOutputsToInstall = [ "lib" ];
      pathsToLink = [ "/lib" ];
      ignoreCollisions = true;
    };

    base-libs64 = pkgs.buildEnv {
      name = "fhs-base-libs64";
      paths = map lib.getLib (libsFromPkgs pkgs);
      extraOutputsToInstall = [ "lib" ];
      pathsToLink = [ "/lib" ];
      ignoreCollisions = true;
    };
  in lib.mkIf config.environment.lsb.enable (lib.mkMerge [
    {
      environment.sessionVariables.LD_LIBRARY_PATH_AFTER = "${base-libs64}/lib${
          lib.optionalString config.environment.lsb.support32Bit
          ":${base-libs32}/lib"
        }";

      environment.etc."lsb".source = pkgs.symlinkJoin {
        name = "lsb-combined";
        paths = [
          base-libs64
          base-libs32
        ];
      };

      environment.systemPackages = with pkgs;
        [
          # Core
          bc
          gnum4
          man
          lsb-release
          file
          psmisc
          ed
          gettext
          utillinux

          # Languages
          perl
          python3

          # Misc.
          pciutils
          which
          usbutils

          # Bonus
          bzip2

          # Desktop
          xdg_utils
          xorg.xrandr
          fontconfig
          cups

          # Imaging
          foomatic-filters
          ghostscript
        ] ++ libsFromPkgs pkgs
        ++ lib.optionals (config.environment.lsb.support32Bit)
        (libsFromPkgs pkgs.pkgsi686Linux);

    }
  ]);

}
