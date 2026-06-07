{ pkgs }:
{
  buf = pkgs.callPackage ./buf { };
  go = pkgs.callPackage ./go { };
  kubeVip = pkgs.callPackage ./kube-vip { };
  upjet = pkgs.callPackage ./upjet { };
}
