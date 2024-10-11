{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    git
    python3
    curl
    xclip
    gcc
    eza
    ripgrep
    fd
    fzf
    adw-gtk3
    ddcutil
    nh

    chromium
    vscodium
    signal-desktop
    inputs.wezterm.packages.${pkgs.system}.default
    gnome-tweaks
    btrfs-assistant
    solaar
    vlc
    lutris
    calibre
    drawing
    krita
    vesktop
    gcolor3
    libreoffice
    speedcrunch
    virt-manager
    virtiofsd

    (lib.hiPrio (writeShellScriptBin "python3" ''LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH exec -a $0 ${python3}/bin/python3 "$@"'')) # nix-ld fix

    gnomeExtensions.arcmenu
    gnomeExtensions.appindicator
    gnomeExtensions.brightness-control-using-ddcutil
    gnomeExtensions.disable-workspace-animation
    gnomeExtensions.just-perfection
    gnomeExtensions.removable-drive-menu
    gnomeExtensions.solaar-extension
    gnomeExtensions.bluetooth-battery-meter
  ];

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [ gnome-shell-extensions epiphany ];

  programs.firefox = {
    enable = true;
    autoConfig = builtins.readFile(builtins.fetchurl {  
      url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/master/program/config.js";
      sha256 = "1mx679fbc4d9x4bnqajqx5a95y1lfasvf90pbqkh9sm3ch945p40";
    });
  };

  programs.fish.enable = true;

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

  # Make normal binaries work
  programs.nix-ld = {
    enable = true;
    libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
  };

  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 3;
    TIMELINE_LIMIT_DAILY = 3;
    TIMELINE_LIMIT_WEEKLY = 0;
    TIMELINE_LIMIT_MONTHLY = 0;
    TIMELINE_LIMIT_YEARLY = 0;
  };

  services.fwupd.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.logitech.wireless.enable = true;

  services.printing.enable = true;

  # Fix Microsoft fonts at small sizes
  fonts.fontconfig.useEmbeddedBitmaps = false;

  environment.sessionVariables = {
    QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor"; # Fix Calibre viewer in HiDPI
    QT_QPA_PLATFORM = "wayland"; # Make Qt apps use Wayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto"; # Make Electron apps use Wayland
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.containers.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Monitor brightness control
  hardware.i2c.enable = true;

  services.cloudflare-warp.enable = true;

  zramSwap.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/".options = [ "subvol=@" "compress-force=zstd:3" ];
  fileSystems."/home".options = [ "subvol=@home" "compress-force=zstd:3" ];

  users.users.chika = {
    isNormalUser = true;
    description = "Chika";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
    shell = pkgs.fish;
  };

  networking.networkmanager.enable = true;
  networking.hostName = "nixos";

  time.timeZone = "America/New_York";

  nix = {
    optimise.automatic = true; # hard link
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
