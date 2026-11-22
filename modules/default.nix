{ inputs, ... }:
{
  flake.flakeModules.ci = ./ci;

  perSystem =
    { pkgs, system, ... }:
    {
      checks.ci-module = pkgs.callPackage ./ci/test.nix {
        inherit (inputs) flake-parts systems;
        inherit system;
      };
    };
}
