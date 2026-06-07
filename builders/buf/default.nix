{ self, ... }:
{
  flake.lib.bufTools =
    { pkgs }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        build = callPackage ./build.nix;
        buildBin = callPackage ./build-bin.nix;
        convert = callPackage ./convert.nix;
        generate = callPackage ./generate.nix;
      };
    in
    packages;

  perSystem =
    { pkgs, ... }:
    {
      legacyPackages.bufTools = self.lib.bufTools { inherit pkgs; };
    };
}
