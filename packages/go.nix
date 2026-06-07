{
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
        inherit (self'.legacyPackages) mangoTools;
        inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication;

        chart-releaser = callPackage ./chart-releaser { };
        kubectl-get-all = callPackage ./kubectl-get-all { };
        kubectl-get-resources = callPackage ./kubectl-get-resources { };
        kubectl-slice = callPackage ./kubectl-slice { };
        mmake = callPackage ./mmake { };
        openshift-installer = callPackage ./openshift-installer { };
        smarter-device-manager = callPackage ./smarter-device-manager { };
        terraform-plugin-codegen-openapi = callPackage ./terraform-plugin-codegen-openapi { };
        terraform-provider-pfsense = callPackage ./terraform-provider-pfsense { };
        terraform-providers = callPackage ./terraform-providers { };
      };
    in
    {
      packages = {
        inherit (packages)
          chart-releaser
          kubectl-get-all
          kubectl-get-resources
          kubectl-slice
          mmake
          openshift-installer
          smarter-device-manager
          terraform-plugin-codegen-openapi
          terraform-provider-pfsense
          ;
      };

      legacyPackages = {
        inherit (packages)
          chart-releaser
          kubectl-get-all
          kubectl-get-resources
          mmake
          openshift-installer
          smarter-device-manager
          terraform-providers
          ;
      };
    };
}
