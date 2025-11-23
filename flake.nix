{
  description = "Random Nix crap";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    gomod2nix.url = "github:nix-community/gomod2nix?ref=v1.7.0";
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
      imports = [
        inputs.treefmt-nix.flakeModule
        # https://flake.parts/overlays.html#an-overlay-for-free-with-flake-parts
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      perSystem =
        {
          config,
          pkgs,
          system,
          final,
          ...
        }:
        {
          overlayAttrs = {
            inherit (config.packages) gomod2nix;
          };

          # TODO: This is broken
          # packages.chart-releaser = pkgs.callPackage ./pkgs/chart-releaser {
          #   inherit (inputs.gomod2nix.legacyPackages.${system}) buildGoApplication;
          # };

          packages.gomod2nix = inputs.gomod2nix.packages.${system}.default;

          devShells.default = pkgs.mkShellNoCC {
            nativeBuildInputs = with pkgs; [
              final.gomod2nix
              nil
              nixd
              nixfmt-rfc-style
              nurl
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };
        };
    };
}
