{
  lib,
  runCommand,
  nodejs_24,
  typescript,
}:
runCommand "ci-health"
  {
    src = lib.fileset.toSource {
      root = ../../.github/actions/ci-health;
      fileset = ../../.github/actions/ci-health;
    };
    nativeBuildInputs = [
      nodejs_24
      typescript
    ];
  }
  ''
    cd $src
    node --test aggregate.test.mjs
    tsc -p jsconfig.json
    touch $out
  ''
