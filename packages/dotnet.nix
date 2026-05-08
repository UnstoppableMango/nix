{
  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    let
      callPackage = lib.callPackageWith (packages // pkgs);

      packages = {
        aspire-cli = callPackage ./aspire-cli { };
      };
    in
    {
      inherit packages;

      legacyPackages = {
        inherit (packages) aspire-cli;
      };
    };
}
