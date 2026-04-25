{
  imports = [
    ./kubectl-get-all
    ./kubectl-get-resources
    ./mmake
    ./omnissa-horizon-client
    ./openshift-installer
    ./smarter-device-manager
  ];

  perSystem =
    { pkgs, ... }:
    let
      aspire-cli = pkgs.callPackage ./aspire-cli { };
      chart-releaser = pkgs.callPackage ./chart-releaser { };
    in
    {
      packages = { inherit aspire-cli chart-releaser; };

      apps = {
        aspire-cli = {
          type = "app";
          meta.description = "A CLI tool for managing Aspire projects";
          program = "${aspire-cli}/bin/aspire";
        };
      };
    };
}
