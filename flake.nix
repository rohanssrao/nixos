{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.disko.url = "github:nix-community/disko/latest";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { ... }@inputs: {
    nixosConfigurations."nixos" = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = with pkgs; [
            nh
            git
            python3
            uv
            curl
            xclip
            gcc
            eza
            ripgrep
            fd
            fzf
            adw-gtk3
            ddcutil

            ghostty
            chromium
            vscodium
            obsidian
            lutris
            steam
            vlc
            libreoffice
            vesktop
            speedcrunch
            qbittorrent
            gnome-tweaks
            btrfs-assistant
            solaar
            calibre
            krita
            drawing
            gcolor3

            (lib.hiPrio (writeShellScriptBin "python" ''LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH exec -a $0 ${lib.getExe python3} "$@"'')) # nix-ld fix

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

          environment.sessionVariables.NIXOS_OZONE_WL = "1";

          programs.firefox = {
            enable = true;
            autoConfig = builtins.readFile(builtins.fetchurl {  
              url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/master/program/config.js";
              sha256 = "1mx679fbc4d9x4bnqajqx5a95y1lfasvf90pbqkh9sm3ch945p40";
            });
          };

          programs.fish.enable = true;

          documentation.man.generateCaches = false;

          programs.command-not-found.enable = false;

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
            libraries = pkgs.steam-run.args.multiPkgs pkgs;
          };

          services.cloudflare-warp.enable = true;

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

          systemd.tmpfiles.rules = [
            "v /home/.snapshots 0700 root root"
            "Z /etc/nixos 0755"
          ];

          services.fwupd.enable = true;

          hardware.logitech.wireless.enable = true;

          services.printing.enable = true;

          virtualisation.podman.enable = true;
          virtualisation.podman.dockerCompat = true;

          hardware.graphics.enable32Bit = true;

          # Monitor brightness control
          hardware.i2c.enable = true;

          zramSwap.enable = true;

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          time.timeZone = "America/New_York";

          networking.hostName = "nixos";

          users.users.chika = {
            isNormalUser = true;
            description = "Chika";
            extraGroups = [ "networkmanager" "wheel" "i2c" ];
            shell = pkgs.fish;
            hashedPassword = "$y$j9T$y0RtVrfPUu49GvNhTuRFT0$IhXJgc3GAuxzokygUoqKLwsy2T/7L0eMs4pjgfMWLe1";
          };

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

        })

        # git clone git@github.com:rohanssrao/nixos.git /tmp/config/etc/nixos
        # cd /tmp/config/etc/nixos
        # nixos-generate-config --show-hardware-config --no-filesystems > hardware-configuration.nix
        # lsblk
        # sudo nix --experimental-features 'nix-command flakes' run 'github:nix-community/disko/latest#disko-install' -- --flake .#nixos --write-efi-boot-entries --disk main /dev/replaceme
        inputs.disko.nixosModules.disko {
          disko.devices.disk.main = {
            type = "disk";
            device = "/dev/replaceme";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  priority = 1;
                  size = "1024M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                  };
                };
                root = {
                  size = "100%";
                  content = {
                    # type = "luks";
                    # name = "crypted";
                    # settings.allowDiscards = true;
                    # content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ];
                      subvolumes = {
                        "@" = {
                          mountpoint = "/";
                          mountOptions = [ "compress-force=zstd" "noatime" ];
                        };
                        "@home" = {
                          mountpoint = "/home";
                          mountOptions = [ "compress-force=zstd" "noatime" ];
                        };
                      };
                    # };
                  };
                };
              };
            };
          };
        }

      ];
    };
  };
}
