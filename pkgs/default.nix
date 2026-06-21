{
  perSystem =
    {
      inputs',
      self',
      pkgs,
      lib,
      ...
    }:
    let
      callPackage = lib.callPackageWith (packages // pkgs);

      packages = {
        inherit (self'.legacyPackages) mangoTools;
        inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication;

        omnissa-horizon-client = callPackage ./omnissa-horizon-client { };
        terraform-providers = callPackage ./terraform-providers { };
      };
    in
    {
      packages = {
        inherit (packages) omnissa-horizon-client;
      };

      legacyPackages = {
        inherit (packages) omnissa-horizon-client terraform-providers;
      };
    };
}
