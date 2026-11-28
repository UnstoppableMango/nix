{
  flake-parts,
  hercules-ci-effects,
  systems,
  system,
  pkgs,
  lib,
  runCommand,
  emptyDirectory,
  writeText,
}:
let
  consumer =
    module:
    flake-parts.lib.mkFlake
      {
        inputs = {
          inherit flake-parts;
          self = { };
        };
      }
      {
        systems = [ system ];
        imports = [
          (flake-parts.lib.importApply ../../modules/ci { inherit hercules-ci-effects; })
          module
        ];
        perSystem._module.args.pkgs = pkgs;
      };

  bare = consumer { };
  off = consumer { ci.hercules.enable = false; };
  # nix-systems also sets ciSystems.
  beside = consumer systems.flakeModule;

  # ciSystems is the checking system, so the jobs can be read on any system.
  full = consumer {
    flake.herculesCI.ciSystems = lib.mkForce [ system ];

    ci = {
      attic.enable = true;
      exclude.packages = [ "broken" ];
      nightly.packages = [ "flaky" ];
    };

    perSystem = {
      packages = {
        app = writeText "app" "";
        broken = writeText "broken" "";
        flaky = writeText "flaky" "";
      };
      checks.fmt = writeText "fmt" "";
      devShells.default = emptyDirectory;

      ci.fixup.steps = [
        "touch fixed"
        "test -f fixed"
      ];
    };
  };

  names = lib.mapAttrs (_: outputs: builtins.attrNames outputs.${system});
  inherit (full.herculesCI) onPush onSchedule;
in
assert bare.herculesCI.ciSystems == [ "x86_64-linux" ];
assert beside.herculesCI.ciSystems == [ "x86_64-linux" ];
assert
  names onPush.default.outputs == {
    checks = [ "fmt" ];
    packages = [ "app" ];
  };
assert
  onSchedule.nightly.when == {
    hour = [ 4 ];
    minute = 0;
  };
assert
  names onSchedule.nightly.outputs == {
    checks = [ ];
    packages = [ "flaky" ];
    devShells = [ "default" ];
    effects = [ "attic-push" ];
  };
# The push carries the default and nightly outputs, not the excluded ones.
assert
  let
    inherit (onSchedule.nightly.outputs.effects.${system}.attic-push) effectScript;
  in
  lib.all (name: lib.hasInfix "-${name}" effectScript) [
    "app"
    "fmt"
    "flaky"
  ]
  && !lib.hasInfix "-broken" effectScript;
assert !bare.herculesCI.onSchedule.nightly.outputs ? effects;
assert off.herculesCI.onPush == { };
assert !off.herculesCI ? onSchedule;
assert off.herculesCI.ciSystems == [ "x86_64-linux" ];
runCommand "ci-module" { } ''
  mkdir work && cd work
  ${bare.apps.${system}.renovate-fixup.program}
  test -z "$(ls -A)"
  ${full.apps.${system}.renovate-fixup.program}
  test -f fixed
  touch $out
''
