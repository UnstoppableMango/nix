{
  perSystem =
    { self', pkgs, ... }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        inherit (self'.legacyPackages) mangoTools;
        kube-vip = callPackage ./main.nix { };
      };
    in
    {
      packages = {
        inherit (packages) kube-vip;
      };

      legacyPackages = {
        inherit (packages) kube-vip;
      };
    };
}
