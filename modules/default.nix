{ inputs, flake-parts-lib, ... }:
{
  flake.flakeModules.ci = flake-parts-lib.importApply ./ci { inherit (inputs) hercules-ci-effects; };
}
