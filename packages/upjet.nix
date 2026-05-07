{
  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    let
      callPackage = lib.callPackageWith (packages // pkgs);

      packages = {
        inherit (self'.legacyPackages) mangoTools upjetTools;
        upjet-provider-cloudflare = callPackage ./upjet-provider-cloudflare { };
      };
    in
    {
      packages = {
        inherit (packages) upjet-provider-cloudflare;
      };

      legacyPackages = {
        inherit (packages) upjet-provider-cloudflare;
      };
    };
}
