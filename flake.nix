{
  description = "@tlvince's NixOS config";

  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "git+https://github.com/nix-community/home-manager?shallow=1&ref=master";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    secrets.flake = false;
    secrets.url = "github:tlvince/nixos-config-secrets";
    tmux-colours-onedark.flake = false;
    tmux-colours-onedark.url = "github:tlvince/tmux-colours-onedark";
  };

  outputs = {
    agenix,
    disko,
    home-manager,
    lanzaboote,
    nixpkgs,
    secrets,
    self,
    tmux-colours-onedark,
    ...
  } @ inputs: let
    keys = import ./keys.nix;
  in {
    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in
      pkgs.mkShellNoCC {
        packages = with pkgs; [
          alejandra
        ];
      };
    devShells.x86_64-linux.nodejs = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
      pkgs.mkShellNoCC {
        packages = with pkgs; [
          azure-cli
          eslint_d
          nodePackages."@astrojs/language-server"
          nodePackages.bash-language-server
          nodePackages.typescript-language-server
          nodejs_22
          mongodb-tools
          mongosh
          terraform
          terraform-ls
        ];
      };
    nixosConfigurations = {
      cm3588 = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit keys;
          secrets = import inputs.secrets;
          secretsPath = inputs.secrets.outPath;
        };

        modules = [
          ./cm3588.nix
          agenix.nixosModules.default
          disko.nixosModules.disko
        ];
      };
      framework = nixpkgs.lib.nixosSystem {
        specialArgs =
          inputs
          // {
            secretsPath = inputs.secrets.outPath;
          };
        modules = [
          ./configuration.nix
          agenix.nixosModules.default
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = inputs;
            home-manager.useGlobalPkgs = true;
            home-manager.users.tlv = import ./home.nix;
          }
          lanzaboote.nixosModules.lanzaboote
        ];
      };
      kernel = nixpkgs.lib.nixosSystem {
        specialArgs = inputs;
        modules = [
          (
            {
              pkgs,
              lib,
              config,
              ...
            }: {
              boot = {
                kernelPackages = pkgs.linuxPackages_latest;
                loader.grub.device = "/dev/disk/by-id/wwn-0x500001234567890a";
              };

              fileSystems."/" = {
                device = "/";
                fsType = "btrfs";
              };

              nixpkgs.overlays = [
                (
                  final: prev: {
                    # mt7925e 0000:c0:00.0: probe with driver mt7925e failed with error -5
                    # https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/log/mediatek/mt7925
                    linux-firmware = prev.linux-firmware.overrideAttrs (
                      old: {
                        version = "20250613";
                        src = pkgs.fetchzip {
                          url = "https://cdn.kernel.org/pub/linux/kernel/firmware/linux-firmware-20250613.tar.xz";
                          hash = "sha256-qygwQNl99oeHiCksaPqxxeH+H7hqRjbqN++Hf9X+gzs=";
                        };
                      }
                    );
                  }
                )
              ];

              nix.settings = {
                experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                extra-substituters = [
                  "https://tlvince-nixos-config.cachix.org"
                  "https://nix-community.cachix.org"
                ];
                extra-trusted-public-keys = [
                  "tlvince-nixos-config.cachix.org-1:PYVWI+uNlq7mSJxFSPDkkCEtaeQeF4WvjtQKa53ZOyM="
                  "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                ];
              };

              nixpkgs.config.allowUnfree = true;
              nixpkgs.hostPlatform = "x86_64-linux";

              system.stateVersion = "25.11";
            }
          )
        ];
      };
    };
  };
}
