{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (packages // pkgs);

  packages = {
    buildProviderRepo = callPackage ./provider-repo.nix;
    buildProvider = callPackage ./provider.nix;
  };
in
packages
