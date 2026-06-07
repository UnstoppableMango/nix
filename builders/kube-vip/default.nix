{ self, ... }:
{
  flake.lib.kubeVipTools =
    { pkgs, kube-vip }:
    let
      callPackage = pkgs.lib.callPackageWith (kubeVipTools // pkgs);

      kubeVipTools = {
        inherit kube-vip;
        manifestPod = callPackage ./manifest-pod.nix;
      };
    in
    kubeVipTools;

  perSystem =
    { self', pkgs, ... }:
    {
      legacyPackages.kubeVipTools = self.lib.kubeVipTools {
        inherit pkgs;
        kube-vip = self'.legacyPackages.kube-vip;
      };
    };
}
