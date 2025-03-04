{
  description = "Boticelli's dotfiles for nixOS";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, ...  }: 
  let
    # inherit (self) outputs;
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # replace with your hostname
      nixos = lib.nixosSystem {
        # specialArgs = {inherit inputs outputs;};
        # > Our main nixos configuration file <
        # system = "x86_64-linux";
        inherit system;
        modules = [ ./nixos/configuration.nix ];
      };
    };

    homeConfigurations = {
      boticelli = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        module = [ ./home-manager/home.nix ];
      };
    };
    
    # # Standalone home-manager configuration entrypoint
    # # Available through 'home-manager --flake .#your-username@your-hostname'
    # homeConfigurations = {
    #   # replace with your username@hostname
    #   "boticelli@nixos" = home-manager.lib.homeManagerConfiguration {
    #     pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
    #     extraSpecialArgs = {inherit inputs outputs;};
    #     # > Our main home-manager configuration file <
    #     modules = [./home-manager/home.nix];
    #   };
    # };
  };
}
