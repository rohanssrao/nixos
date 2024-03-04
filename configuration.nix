{ self, config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    git
    python3
    wget
    curl
    fish
    lunarvim
    xclip
    gcc
    eza
    ripgrep
    fd
    fzf
    tealdeer
    compsize
    spotdl 
    tmux
    distrobox
    wireguard-tools
    adw-gtk3
    ddcutil

    burpsuite
    blackbox-terminal
    gnome.dconf-editor
    gnome.gnome-tweaks
    btrfs-assistant
    vscode
    vlc
    lutris
    calibre
    drawing
    pdfarranger
    video-trimmer
    switcheroo
    obs-studio
    xournalpp
    haguichi
    microsoft-edge
    vesktop
    obsidian
    gcolor3
    meld
    libreoffice
    qbittorrent
    speedcrunch
    zoom-us
    virt-manager
    virtiofsd
    tor-browser
    krita
    gnome-network-displays

    gnomeExtensions.arcmenu
    gnomeExtensions.appindicator
    gnomeExtensions.brightness-control-using-ddcutil
    gnomeExtensions.disable-workspace-animation
    gnomeExtensions.gesture-improvements
    gnomeExtensions.just-perfection
    gnomeExtensions.removable-drive-menu
  ];

  programs.firefox = {
    enable = true;
    autoConfig =
      ''
        try {
          let cmanifest = Cc['@mozilla.org/file/directory_service;1'].getService(Ci.nsIProperties).get('UChrm', Ci.nsIFile);
          cmanifest.append('utils');
          cmanifest.append('chrome.manifest');
          if(cmanifest.exists()){
            Components.manager.QueryInterface(Ci.nsIComponentRegistrar).autoRegister(cmanifest);
            ChromeUtils.importESModule('chrome://userchromejs/content/boot.sys.mjs');
          }
        } catch(ex) {};
      '';
  };

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  services.snapper = {
    configs.home = {
      SUBVOLUME = "/home";
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 3;
      TIMELINE_LIMIT_DAILY = 3;
      TIMELINE_LIMIT_WEEKLY = 3;
      TIMELINE_LIMIT_MONTHLY = 0;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;
  # services.logmein-hamachi.enable = true;

  virtualisation.libvirtd.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.containers.enable = true;

  # Set external display as primary in GDM
  systemd.tmpfiles.rules = [
    ''f+ /run/gdm/.config/monitors.xml - gdm gdm - <monitors version="2"> <configuration> <logicalmonitor> <x>0</x> <y>0</y> <scale>1</scale> <primary>yes</primary> <monitor> <monitorspec> <connector>HDMI-1</connector> <vendor>LEN</vendor> <product>LEN L23i-18</product> <serial>0x4d473634</serial> </monitorspec> <mode> <width>1920</width> <height>1080</height> <rate>74.986</rate> </mode> </monitor> </logicalmonitor> <disabled> <monitorspec> <connector>eDP-1</connector> <vendor>AUO</vendor> <product>0x20ec</product> <serial>0x00000000</serial> </monitorspec> </disabled> </configuration> </monitors>''
  ];

  imports = [ 
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ./nixos-fhs-compat/default.nix
  ];

  environment.fhs.enable = true;
  environment.fhs.linkLibs = true;
  environment.lsb.enable = true;

  zramSwap.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.i2c.enable = true; # Monitor brightness control

  hardware.opengl.enable = true;

  users.users.chika = {
    isNormalUser = true;
    description = "Rohan";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  fileSystems."/".options = [ "subvol=@" "compress-force=zstd:3" ];
  fileSystems."/home".options = [ "subvol=@home" "compress-force=zstd:3" ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.extraOptions = "warn-dirty = false";

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
