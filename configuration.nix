{ self, config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    git
    python3
    wget
    curl
    xclip
    gcc
    eza
    ripgrep
    fd
    fzf
    bat
    tealdeer
    compsize
    spotdl 
    tmux
    distrobox
    wireguard-tools
    adw-gtk3
    ddcutil
    nh

    burpsuite
    vscode
    microsoft-edge
    obsidian
    blackbox-terminal
    gnome.dconf-editor
    gnome.gnome-tweaks
    btrfs-assistant
    vlc
    lutris
    calibre
    drawing
    krita
    obs-studio
    pdfarranger
    video-trimmer
    switcheroo
    vesktop
    gcolor3
    meld
    libreoffice
    tor-browser
    qbittorrent
    speedcrunch
    virt-manager
    virtiofsd
    gnome-network-displays

    (lib.hiPrio (writeShellScriptBin "python3" ''LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH exec -a $0 ${python3}/bin/python3 "$@"'')) # nix-ld fix

    gnomeExtensions.arcmenu
    gnomeExtensions.appindicator
    gnomeExtensions.brightness-control-using-ddcutil
    gnomeExtensions.disable-workspace-animation
    gnomeExtensions.just-perfection
    gnomeExtensions.removable-drive-menu
  ];

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs; [ gnome.gnome-shell-extensions epiphany ];

  programs.firefox = {
    enable = true;
    autoConfig = builtins.readFile(builtins.fetchurl {  
      url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/master/program/config.js";
      sha256 = "1mx679fbc4d9x4bnqajqx5a95y1lfasvf90pbqkh9sm3ch945p40";
    });
  };

  programs.fish = {
    enable = true;
    vendor.completions.enable = false;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  programs.gnupg.agent.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
  };

  services.envfs.enable = true;

  services.snapper = {
    configs.home = {
      SUBVOLUME = "/home";
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 3;
      TIMELINE_LIMIT_DAILY = 3;
      TIMELINE_LIMIT_WEEKLY = 0;
      TIMELINE_LIMIT_MONTHLY = 0;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;

  services.fwupd.enable = true;

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.xserver = {
    enable = true;
    xkb = { layout = "us"; variant = ""; };
  };

  fonts.fontconfig.useEmbeddedBitmaps = false;

  virtualisation.libvirtd.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.containers.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;

  fileSystems."/".options = [ "subvol=@" "compress-force=zstd:3" ];
  fileSystems."/home".options = [ "subvol=@home" "compress-force=zstd:3" ];

  zramSwap.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.i2c.enable = true; # Monitor brightness control

  # Set external display as primary in GDM
  systemd.tmpfiles.rules = [ ''f+ /run/gdm/.config/monitors.xml - gdm gdm - <monitors version="2"> <configuration> <logicalmonitor> <x>0</x> <y>0</y> <scale>1</scale> <primary>yes</primary> <monitor> <monitorspec> <connector>HDMI-1</connector> <vendor>LEN</vendor> <product>LEN L23i-18</product> <serial>0x4d473634</serial> </monitorspec> <mode> <width>1920</width> <height>1080</height> <rate>74.986</rate> </mode> </monitor> </logicalmonitor> <disabled> <monitorspec> <connector>eDP-1</connector> <vendor>AUO</vendor> <product>0x20ec</product> <serial>0x00000000</serial> </monitorspec> </disabled> </configuration> </monitors>'' ];

  # Sometimes kills rebuilds
  systemd.services.NetworkManager-wait-online.enable = false;

  users.users.chika = {
    isNormalUser = true;
    description = "Rohan";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
    shell = pkgs.fish;
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    optimise.automatic = true;
    gc.automatic = true;
    gc.options = "--delete-older-than 5d";
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.11";

  imports = [ 
    ./hardware-configuration.nix
  ];

}
