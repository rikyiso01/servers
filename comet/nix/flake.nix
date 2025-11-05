{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  };

  outputs =
    { nixpkgs
    , disko
    , impermanence
    , self
    , ...
    }:
    {
      nixosConfigurations.comet = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          ./configuration.nix
          ./hardware-configuration.nix
          {
            _module.args = { self = self; };
          }
        ];
      };
    };
}
