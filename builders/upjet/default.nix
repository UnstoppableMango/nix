{
  perSystem =
    { inputs', pkgs, ... }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      upjetTools = {
        buildProviderRepo = callPackage ./provider-repo.nix;
        buildProvider = callPackage ./provider.nix;
      };

      legacyPackages = {
        inherit upjetTools;
        buildUpjetProvider = upjetTools.buildProvider;
        buildUpjetProviderRepo = upjetTools.buildProviderRepo;
      };

      packages = {
        inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication gomod2nix;
        inherit (legacyPackages) buildUpjetProvider buildUpjetProviderRepo;
        inherit upjetTools;
      };
    in
    {
      inherit legacyPackages;
    };
}
