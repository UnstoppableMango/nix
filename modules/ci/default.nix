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

  nameList = mkOption {
    type = types.listOf types.str;
    default = [ ];
  };

  outputs = type: system: removeAttrs (config.flake.${type}.${system} or { }) cfg.exclude.${type};

  # Names missing on a system are skipped.
  pick = attrs: wanted: lib.filterAttrs (name: _: builtins.elem name wanted) attrs;

  job =
    select:
    lib.genAttrs [ "checks" "packages" ] (
      type: forCiSystems (system: select (outputs type system) cfg.nightly.${type})
    );
in
{
  options = {
    # nix-systems also sets herculesCI.ciSystems.
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
        checks = nameList // {
          description = "Checks built by no job.";
        };
        packages = nameList // {
          description = "Packages built by no job, such as one broken upstream. Name its tracking issue in a comment.";
        };
        devShells = nameList // {
          description = "devShells built by no job.";
        };
      };

      nightly = {
        checks = nameList // {
          description = "Checks moved from `onPush.default` to the nightly job.";
        };
        packages = nameList // {
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

      onPush.default.outputs = job removeAttrs;

      onSchedule.nightly = {
        when = {
          hour = [ 4 ];
          minute = 0;
        };
        outputs = job pick // {
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
