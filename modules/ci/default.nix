{ hercules-ci-effects }:
{
  config,
  lib,
  flake-parts-lib,
  withSystem,
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

  # Scheduled jobs run on the default branch only, the one branch the agent
  # hands the `attic` secret to.
  atticPush = forCiSystems (
    system:
    withSystem system (
      { pkgs, ... }:
      let
        paths = lib.concatMap (type: lib.attrValues (outputs type system)) [
          "checks"
          "packages"
        ];
      in
      {
        attic-push = (hercules-ci-effects.lib.withPkgs pkgs).mkEffect {
          secretsMap.attic = "attic";
          inputs = [ pkgs.attic-client ];
          effectScript = ''
            attic login thecluster "$(readSecretString attic .endpoint)" "$(readSecretString attic .token)"
            attic push "thecluster:$(readSecretString attic .cache)" ${lib.escapeShellArgs paths}
          '';
        };
      }
    )
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
      # Without a `herculesCI` output Hercules builds a default job from the
      # standard outputs, so off keeps the output and gives it no jobs.
      hercules.enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether Hercules CI gets jobs. Turn it off in a private repo, which Hercules charges for.";
      };

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

      # Off until gaea's bare-metal agents, which lack the `attic` secret, stop
      # taking tasks (UnstoppableMango/nixos#530).
      attic.enable = lib.mkEnableOption "the nightly effect pushing every default and nightly check and package to attic";

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
    flake.herculesCI = lib.mkMerge [
      { ciSystems = lib.mkDefault [ "x86_64-linux" ]; }
      (lib.mkIf (!cfg.hercules.enable) { onPush = { }; })
      (lib.mkIf cfg.hercules.enable {
        onPush.default.outputs = job removeAttrs;

        onSchedule.nightly = {
          when = {
            hour = [ 4 ];
            minute = 0;
          };
          outputs =
            job pick
            // {
              devShells = forCiSystems (outputs "devShells");
            }
            // lib.optionalAttrs cfg.attic.enable { effects = atticPush; };
        };
      })
    ];

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
