{
  perSystem =
    { self', pkgs, ... }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      kubeVipTools = {
        manifestPod = callPackage ./manifest-pod.nix;
        src = callPackage ./src.nix;
      };

      legacyPackages = { inherit kubeVipTools; };

      packages = {
        inherit (self'.legacyPackages.kubeVipPackages) kube-vip;
        inherit kubeVipTools;
      };
    in
    {
      inherit legacyPackages;
    };
}
