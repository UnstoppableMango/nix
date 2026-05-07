{
  perSystem =
    { self', pkgs, ... }:
    let
      callPackage = pkgs.lib.callPackageWith (kubeVipTools // pkgs);

      kubeVipTools = {
        inherit (self'.legacyPackages) kube-vip;
        manifestPod = callPackage ./manifest-pod.nix;
      };
    in
    {
      legacyPackages = { inherit kubeVipTools; };
    };
}
