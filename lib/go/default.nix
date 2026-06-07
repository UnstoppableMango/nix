{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (packages // pkgs);

  packages = {
    mkUpdateDeps = src: callPackage ./update-deps.nix { inherit src; };
    modInit = src: modulePath: callPackage ./mod-init.nix { inherit src modulePath; };
  };
in
packages
