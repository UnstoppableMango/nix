{
  perSystem =
    { self', pkgs, ... }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        inherit (self'.legacyPackages) mangoTools;

        buildProviderRepo = callPackage ./provider-repo.nix;
        buildProvider = callPackage ./provider.nix;
      };
    in
    {
      legacyPackages.upjetTools = packages;
    };
}
