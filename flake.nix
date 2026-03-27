{
  description = "Random Nix crap";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.inputs.systems.follows = "systems";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.treefmt-nix.flakeModule
        # https://flake.parts/overlays.html#an-overlay-for-free-with-flake-parts
        inputs.flake-parts.flakeModules.easyOverlay
        ./packages
      ];

      flake.templates = {
        default = {
          path = ./templates/default;
          description = "Flake with nix-systems, flake-parts, and treefmt-nix";
        };
        go = {
          path = ./templates/go;
          description = "Go flake with nix-systems, flake-parts, treefmt-nix, and gomod2nix";
        };
      };

      perSystem =
        {
          pkgs,
          system,
          config,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;

            config.allowUnfree = true;

            overlays = [
              inputs.gomod2nix.overlays.default
              inputs.nil.overlays.default
            ];
          };

          overlayAttrs = {
            inherit (config.packages)
              chart-releaser
              gomod2nix
              kubectl-get-all
              kubectl-get-resources
              mmake
              omnissa-horizon-client
              openshift-installer
              ;
          };

          apps.gomod2nix = {
            type = "app";
            program = "${pkgs.gomod2nix}/bin/gomod2nix";
            meta.description = "Convert applications using Go modules to Nix expressions";
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              bashInteractive
              gomod2nix
              nil
              nixfmt
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
