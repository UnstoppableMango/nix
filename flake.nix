{
  description = "Random Nix crap";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    gomod2nix.url = "github:nix-community/gomod2nix";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
    nil.url = "github:oxalica/nil";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [ inputs.treefmt-nix.flakeModule ];
      perSystem =
        { pkgs, ... }:
        {
          packages.chart-releaser = pkgs.callPackage ./pkgs/chart-releaser { };

          devShells.default = pkgs.mkShellNoCC {
            nativeBuildInputs = with pkgs; [
              nil
              nixd
              nixfmt-rfc-style
              nurl
            ];
          };

          treefmt = {
            programs.nixfmt.enable = true;
          };
        };
    };
}
