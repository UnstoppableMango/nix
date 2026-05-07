{
  perSystem =
    { inputs', pkgs, ... }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication gomod2nix;
        mkUpdateDeps = src: callPackage ./update-deps.nix { inherit src; };
        modInit = src: modulePath: callPackage ./mod-init.nix { inherit src modulePath; };
      };
    in
    {
      legacyPackages.mangoTools = packages;
    };
}
