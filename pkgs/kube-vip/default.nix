{
  perSystem =
    {
      inputs',
      self',
      pkgs,
      ...
    }:
    let
      inherit (self'.legacyPackages) kubeVipTools;
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        inherit (self'.legacyPackages) mangoTools;
        inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication;

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
