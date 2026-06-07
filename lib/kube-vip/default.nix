{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (kubeVip // pkgs);

  kubeVip = {
    manifestPod = callPackage ./manifest-pod.nix;
  };
in
kubeVip
