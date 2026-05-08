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
        mmake = callPackage ./mmake { };
        openshift-installer = callPackage ./openshift-installer { };
        smarter-device-manager = callPackage ./smarter-device-manager { };
      };
    in
    {
      packages = {
        inherit (packages)
          chart-releaser
          kubectl-get-all
          kubectl-get-resources
          mmake
          openshift-installer
          smarter-device-manager
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
          ;
      };
    };
}
