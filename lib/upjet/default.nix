{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (packages // pkgs);

  packages = {
    mangoTools = pkgs.callPackage ../go { };
    buildProviderRepo = callPackage ./provider-repo.nix;
    buildProvider = callPackage ./provider.nix;
  };
in
packages
