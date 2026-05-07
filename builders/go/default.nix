{
  perSystem =
    { inputs', pkgs, ... }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication gomod2nix;
        mkUpdateDeps = src: callPackage ./update-deps.nix { inherit src; };
      };
    in
    {
      legacyPackages.mangoTools = {
        inherit (packages) mkUpdateDeps;
      };
    };
}
