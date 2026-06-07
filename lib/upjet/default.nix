{ self, ... }:
{
  flake.lib.upjetTools =
    { pkgs, mangoTools }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        inherit mangoTools;
        buildGoApplication = pkgs.buildGoApplication;
        buildProviderRepo = callPackage ./provider-repo.nix;
        buildProvider = callPackage ./provider.nix;
      };
    in
    packages;

  perSystem =
    { self', pkgs, ... }:
    {
      legacyPackages.upjetTools = self.lib.upjetTools {
        inherit pkgs;
        mangoTools = self'.legacyPackages.mangoTools;
      };
    };
}
