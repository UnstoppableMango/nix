{
  perSystem =
    { pkgs, ... }:
    let
      callPackage = pkgs.lib.callPackageWith (kubeVipTools // pkgs);

      kubeVipTools = {
        manifestPod = callPackage ./manifest-pod.nix;
      };
    in
    {
      legacyPackages = { inherit kubeVipTools; };
    };
}
