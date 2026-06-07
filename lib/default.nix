{ self, ... }:
{
  imports = [
    ./buf
    ./go
    ./kube-vip
    ./upjet
  ];

  flake.lib.mkLib =
    { pkgs, kube-vip }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs // { inherit kube-vip; });

      packages = {
        bufTools = callPackage self.lib.bufTools { };
        mangoTools = callPackage self.lib.mangoTools { };
        kubeVipTools = callPackage self.lib.kubeVipTools { };
        upjetTools = callPackage self.lib.upjetTools { };
      };
    in
    packages;
}
