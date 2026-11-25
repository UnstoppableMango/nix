{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      checks = {
        ci-health = pkgs.callPackage ./ci-health.nix { };
        ci-module = pkgs.callPackage ./ci-module.nix {
          inherit (inputs) flake-parts hercules-ci-effects systems;
          inherit system;
        };
      };
    };
}
