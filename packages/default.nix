{
  imports = [
    ./chart-releaser
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
    in
    {
      packages = { inherit aspire-cli; };

      apps = {
        aspire-cli = {
          type = "app";
          meta.description = "A CLI tool for managing Aspire projects";
          program = "${aspire-cli}/bin/aspire";
        };
      };
    };
}
