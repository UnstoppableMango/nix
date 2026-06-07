{ self, ... }:
{
  flake.lib.mangoTools =
    { pkgs }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        inherit (pkgs) buildGoApplication gomod2nix;
        mkUpdateDeps = src: callPackage ./update-deps.nix { inherit src; };
        modInit = src: modulePath: callPackage ./mod-init.nix { inherit src modulePath; };
      };
    in
    packages;

  perSystem =
    { pkgs, ... }:
    {
      legacyPackages.mangoTools = self.lib.mangoTools { inherit pkgs; };
    };
}
