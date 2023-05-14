{
  description = "NixOS configuration";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home manager for dotfiles configuration and managment
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";

      # We want to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, ... }: {
    nixosConfigurations = {
      nixprl = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ({ config, pkgs, ... }:
            let
              overlay-unstable = final: prev: {
                unstable = nixpkgs-unstable.legacyPackages.aarch64-linux;
              };
            in
            {
              nixpkgs.overlays = [ overlay-unstable ];

              imports = [
                  ./hardware-configuration.nix
                  ./configuration.nix
              home-manager.nixosModules.home-manager {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
	                users.mudrii = import ./home-manager;
                  };
                }
	            ];
            }
          )
        ];
      };
    };
  };
}
