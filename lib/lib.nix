{ pkgs, lib }:
let
  callPackage = lib.callPackageWith (packages // pkgs);

  packages = {
    buf = callPackage ./buf { };
    go = callPackage ./go { };
    kubeVip = callPackage ./kube-vip { };
    upjet = callPackage ./upjet { };
  };
in
packages
