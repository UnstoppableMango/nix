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

    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
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

      imports = with inputs; [
        treefmt-nix.flakeModule
        # https://flake.parts/overlays.html#an-overlay-for-free-with-flake-parts
        flake-parts.flakeModules.easyOverlay

        ./lib
        ./pkgs
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
        ocaml = {
          path = ./templates/ocaml;
          description = "OCaml flake with nix-systems, flake-parts, treefmt-nix, and dune";
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
            overlays = with inputs; [
              gomod2nix.overlays.default
              nil.overlays.default
              (_: prev: {
                lib = prev.lib.extend (
                  _: lprev: {
                    maintainers = lprev.maintainers // (import ./lib/maintainers.nix);
                  }
                );
              })
            ];
          };

          overlayAttrs = {
            inherit (config.packages)
              awxkit
              chart-releaser
              kubectl-get-all
              kubectl-get-resources
              kubectl-slice
              mmake
              openshift-installer
              terraform-plugin-codegen-framework
              terraform-plugin-codegen-openapi
              ;
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              bashInteractive
              gomod2nix
              nil
              nix-update
              nixfmt
              nurl
              watchexec
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };
        };
    };
}
