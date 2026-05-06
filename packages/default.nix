{
  perSystem =
    {
      inputs',
      self',
      pkgs,
      ...
    }:
    let
      callPackage = pkgs.lib.callPackageWith (
        { inherit (self'.legacyPackages) upjetTools kubeVipTools; } // legacyPackages // pkgs
      );

      kubeVipPackages = callPackage ./kube-vip { };

      packages = {
        inherit (kubeVipPackages) kube-vip;

        aspire-cli = callPackage ./aspire-cli { };
        chart-releaser = callPackage ./chart-releaser { };
        kubectl-get-all = callPackage ./kubectl-get-all { };
        kubectl-get-resources = callPackage ./kubectl-get-resources { };
        mmake = callPackage ./mmake { };
        omnissa-horizon-client = callPackage ./omnissa-horizon-client { };
        openshift-installer = callPackage ./openshift-installer { };
        smarter-device-manager = callPackage ./smarter-device-manager { };
        upjet-provider-cloudflare = callPackage ./upjet-provider-cloudflare { };
      };

      legacyPackages = {
        inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication gomod2nix;
        inherit kubeVipPackages;
      }
      // packages;
    in
    {
      inherit legacyPackages packages;
    };
}
