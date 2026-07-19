{
  description = "A Gossamer flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/triplet";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangopkgs = {
      url = "github:unmango/pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        { pkgs, inputs', ... }:
        {
          devShells.default = pkgs.mkShellNoCC {
            packages = [
              inputs'.mangopkgs.packages.gossamer
              pkgs.gnumake
              pkgs.nixfmt
            ];
          };

          treefmt.programs = {
            nixfmt.enable = true;
          };
        };
    };
}
