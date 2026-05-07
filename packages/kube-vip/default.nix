{
  perSystem =
    { self', pkgs, ... }:
    let
      inherit (self'.legacyPackages) kubeVipTools;
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        inherit (self'.legacyPackages) mangoTools;

        kube-vip = callPackage ./main.nix { };
        example-manifest = kubeVipTools.manifestPod {
          address = "192.168.0.1";
          interface = "eth0";
          extraArgs = [
            "--arp"
            "--wireguard"
          ];
        };
      };
    in
    {
      packages = {
        inherit (packages) kube-vip example-manifest;
      };

      legacyPackages = {
        inherit (packages) kube-vip;
      };
    };
}
