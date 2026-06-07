{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (packages // pkgs);

  packages = {
    genOpenapi = callPackage ./gen-openapi.nix;
  };
in
packages
