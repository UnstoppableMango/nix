{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (kubeVip // pkgs);

  kubeVip = {
    inherit (pkgs) kube-vip;
    manifestPod = callPackage ./manifest-pod.nix;
  };
in
kubeVip
