{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    { nixpkgs
    , impermanence
    , self
    , ...
    }:
    {
      # Use this for all other targets
      # nixos-anywhere --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix <hostname>
      nixosConfigurations.pi4 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
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
