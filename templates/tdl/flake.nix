{
  description = "A TDL flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:UnstoppableMango/nix-systems";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The overlay builds tdl with nixpkgs' go_1_27. If this nixpkgs lacks the
    # Go version tdl needs, drop the follows and use tdl's packages instead.
    tdl = {
      url = "github:UnstoppableMango/tdl";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = with inputs; [
        systems.flakeModule
        treefmt-nix.flakeModule
        tdl.flakeModules.default
      ];

      perSystem =
        {
          config,
          lib,
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.tdl.overlays.default ];
          };

          tdl = {
            enable = true;
            # The whole repository, so a target block's out path stays inside src.
            src = ./.;
            files = [ "model/shop.tdl" ];

            # TODO(UnstoppableMango/tdl#1503): remove once tdl-gmk is opt-in upstream.
            make.enable = false;

            # Verifies committed generated output is current.
            # gen.files = [ "model/shop.tdl" ];
          };

          devShells.default = pkgs.mkShellNoCC {
            inputsFrom = [ config.devShells.tdl ];
            packages = with pkgs; [
              gnumake
              nixfmt
            ];
          };

          treefmt = {
            programs.nixfmt.enable = true;
            settings.formatter.tdl = {
              command = lib.getExe pkgs.tdl;
              options = [
                "fmt"
                "-w"
              ];
              includes = [ "*.tdl" ];
            };
          };
        };
    };
}
