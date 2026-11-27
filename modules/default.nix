{ inputs, flake-parts-lib, ... }:
let
  ci = flake-parts-lib.importApply ./ci { inherit (inputs) hercules-ci-effects; };
in
{
  imports = [ ci ];

  flake.flakeModules.ci = ci;
}
