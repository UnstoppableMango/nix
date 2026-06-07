{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (packages // pkgs);

  packages = {
    inherit (pkgs) mangoTools;
    buildGoApplication = pkgs.buildGoApplication;
    buildProviderRepo = callPackage ./provider-repo.nix;
    buildProvider = callPackage ./provider.nix;
  };
in
packages
