{
  imports = [
    ./apis
    ./kube-vip
    ./images
  ];

  perSystem =
    {
      inputs',
      self',
      pkgs,
      lib,
      ...
    }:
    let
      callPackage = lib.callPackageWith (packages // pkgs);

      packages = {
        inherit (self'.legacyPackages) mangoTools upjetTools;
        inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication;

        aspire-cli = callPackage ./aspire-cli { };
        awxkit = callPackage ./awxkit { };
        chart-releaser = callPackage ./chart-releaser { };
        kubectl-get-all = callPackage ./kubectl-get-all { };
        kubectl-get-resources = callPackage ./kubectl-get-resources { };
        kubectl-slice = callPackage ./kubectl-slice { };
        mmake = callPackage ./mmake { };
        omnissa-horizon-client = callPackage ./omnissa-horizon-client { };
        openshift-installer = callPackage ./openshift-installer { };
        smarter-device-manager = callPackage ./smarter-device-manager { };
        terraform-plugin-codegen-framework = callPackage ./terraform-plugin-codegen-framework { };
        terraform-plugin-codegen-openapi = callPackage ./terraform-plugin-codegen-openapi { };
        terraform-provider-pfsense = callPackage ./terraform-provider-pfsense { };
        terraform-providers = callPackage ./terraform-providers { };
        upjet-provider-cloudflare = callPackage ./upjet-provider-cloudflare { };
      };
    in
    {
      packages = {
        inherit (packages)
          aspire-cli
          awxkit
          chart-releaser
          kubectl-get-all
          kubectl-get-resources
          kubectl-slice
          mmake
          omnissa-horizon-client
          openshift-installer
          smarter-device-manager
          terraform-plugin-codegen-framework
          terraform-plugin-codegen-openapi
          terraform-provider-pfsense
          upjet-provider-cloudflare
          ;
      };

      legacyPackages = {
        inherit (packages)
          aspire-cli
          awxkit
          chart-releaser
          kubectl-get-all
          kubectl-get-resources
          mmake
          omnissa-horizon-client
          openshift-installer
          smarter-device-manager
          terraform-plugin-codegen-framework
          terraform-plugin-codegen-openapi
          terraform-providers
          upjet-provider-cloudflare
          ;
      };
    };
}
