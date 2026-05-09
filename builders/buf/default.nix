{
  perSystem =
    {
      inputs',
      self',
      pkgs,
      ...
    }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        inherit (self'.legacyPackages) mangoTools;
        inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication;

        build = callPackage ./build.nix;
      };
    in
    {
      legacyPackages.bufTools = packages;
    };
}
