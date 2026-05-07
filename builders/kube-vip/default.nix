{
  perSystem =
    { self', pkgs, ... }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      kubeVipTools = {
        manifestPod = callPackage ./manifest-pod.nix;
        src = callPackage ./src.nix;
      };

      legacyPackages = {
        inherit kubeVipTools;
        kubeVipManifestPod = kubeVipTools.manifestPod;
      };

      packages = {
        inherit (legacyPackages) kubeVipTools;
        inherit (self'.legacyPackages.kubeVipPackages) kube-vip;
      };
    in
    {
      inherit legacyPackages;
    };
}
