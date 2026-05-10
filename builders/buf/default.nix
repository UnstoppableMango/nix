{
  perSystem =
    { pkgs, ... }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        build = callPackage ./build.nix;
        buildBin = callPackage ./build-bin.nix;
        convert = callPackage ./convert.nix;
      };
    in
    {
      legacyPackages.bufTools = packages;
    };
}
