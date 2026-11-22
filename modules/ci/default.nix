{
  config,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.ci;
  forCiSystems = lib.genAttrs config.flake.herculesCI.ciSystems;

  names = mkOption {
    type = types.listOf types.str;
    default = [ ];
  };

  # Missing names are skipped, so a list can name what only some systems have.
  pick = attrs: wanted: lib.filterAttrs (name: _: builtins.elem name wanted) attrs;
  omit = attrs: unwanted: removeAttrs attrs unwanted;

  outputs = type: system: omit (config.flake.${type}.${system} or { }) (cfg.exclude.${type} or [ ]);
in
{
  options = {
    # nix-systems sets herculesCI.ciSystems too, so this is an attribute set its
    # keys merge into rather than a second raw definition.
    flake = mkOption {
      type = types.submoduleWith {
        modules = [
          {
            options.herculesCI = mkOption {
              type = types.lazyAttrsOf types.raw;
              default = { };
              description = "The `herculesCI` flake output, read by Hercules CI.";
            };
          }
        ];
      };
    };

    ci = {
      exclude = {
        checks = names // {
          description = "Checks built by no job.";
        };
        packages = names // {
          description = "Packages built by no job, such as one broken upstream. Name its tracking issue in a comment.";
        };
        devShells = names // {
          description = "devShells built by no job.";
        };
      };

      nightly = {
        checks = names // {
          description = "Checks moved from `onPush.default` to the nightly job.";
        };
        packages = names // {
          description = "Packages moved from `onPush.default` to the nightly job.";
        };
      };
    };

    perSystem = flake-parts-lib.mkPerSystemOption {
      options.ci.fixup = {
        steps = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [ "nix develop --command gomod2nix" ];
          description = "Commands `apps.renovate-fixup` runs in order, from the current directory.";
        };
        runtimeInputs = mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = "Packages on the steps' `PATH`.";
        };
      };
    };
  };

  config = {
    flake.herculesCI = {
      ciSystems = lib.mkDefault [ "x86_64-linux" ];

      onPush.default.outputs = {
        checks = forCiSystems (system: omit (outputs "checks" system) cfg.nightly.checks);
        packages = forCiSystems (system: omit (outputs "packages" system) cfg.nightly.packages);
      };

      onSchedule.nightly = {
        when = {
          hour = [ 4 ];
          minute = 0;
        };
        outputs = {
          checks = forCiSystems (system: pick (outputs "checks" system) cfg.nightly.checks);
          packages = forCiSystems (system: pick (outputs "packages" system) cfg.nightly.packages);
          devShells = forCiSystems (outputs "devShells");
        };
      };
    };

    perSystem =
      { config, pkgs, ... }:
      {
        apps.renovate-fixup = {
          type = "app";
          program = lib.getExe (
            pkgs.writeShellApplication {
              name = "renovate-fixup";
              inherit (config.ci.fixup) runtimeInputs;
              text = lib.concatLines config.ci.fixup.steps;
            }
          );
          meta.description = "Refresh what a Renovate update leaves stale";
        };
      };
  };
}
