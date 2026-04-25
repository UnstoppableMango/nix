{
  perSystem =
    { pkgs, ... }:
    let
      aspire-cli = pkgs.callPackage ./aspire-cli { };
      chart-releaser = pkgs.callPackage ./chart-releaser { };
      kubectl-get-all = pkgs.callPackage ./kubectl-get-all { };
      kubectl-get-resources = pkgs.callPackage ./kubectl-get-resources { };
      mmake = pkgs.callPackage ./mmake { };
      omnissa-horizon-client = pkgs.callPackage ./omnissa-horizon-client { };
      openshift-installer = pkgs.callPackage ./openshift-installer { };
      smarter-device-manager = pkgs.callPackage ./smarter-device-manager { };
    in
    {
      packages = {
        inherit
          aspire-cli
          chart-releaser
          kubectl-get-all
          kubectl-get-resources
          mmake
          omnissa-horizon-client
          openshift-installer
          smarter-device-manager
          ;
      };

      apps = {
        aspire-cli = {
          type = "app";
          meta.description = "A CLI tool for managing Aspire projects";
          program = "${aspire-cli}/bin/aspire";
        };
      };
    };
}
