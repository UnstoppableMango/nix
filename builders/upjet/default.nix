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

        buildProviderRepo = callPackage ./provider-repo.nix;
        buildProvider = callPackage ./provider.nix;
      };
    in
    {
      legacyPackages.upjetTools = packages;
    };
}
