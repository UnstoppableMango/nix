{
  flake-parts,
  systems,
  system,
  pkgs,
  lib,
  runCommand,
  emptyFile,
  emptyDirectory,
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
          ./.
          module
        ];
        perSystem._module.args.pkgs = pkgs;
      };

  # Imported beside nix-systems, which also sets ciSystems.
  bare = consumer systems.flakeModule;

  # ciSystems is the checking system, so the jobs can be read on any system.
  full = consumer {
    flake.herculesCI.ciSystems = lib.mkForce [ system ];

    ci = {
      exclude.packages = [ "broken" ];
      nightly.packages = [ "flaky" ];
    };

    perSystem = {
      packages = {
        app = emptyFile;
        broken = emptyFile;
        flaky = emptyFile;
      };
      checks.fmt = emptyFile;
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
  };
runCommand "ci-module" { } ''
  mkdir work && cd work
  ${bare.apps.${system}.renovate-fixup.program}
  test -z "$(ls -A)"
  ${full.apps.${system}.renovate-fixup.program}
  touch $out
''
