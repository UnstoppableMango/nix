{
  imports = [ ./kube-vip ];

  perSystem =
    {
      inputs',
      pkgs,
      self',
      ...
    }:
    let
      inherit (pkgs) callPackage;
      inherit (self'.legacyPackages) buildUpjetProvider;
      inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication;

      aspire-cli = callPackage ./aspire-cli { };
      chart-releaser = callPackage ./chart-releaser { inherit buildGoApplication; };
      kubectl-get-all = callPackage ./kubectl-get-all { inherit buildGoApplication; };
      kubectl-get-resources = callPackage ./kubectl-get-resources { inherit buildGoApplication; };
      mmake = callPackage ./mmake { inherit buildGoApplication; };
      omnissa-horizon-client = callPackage ./omnissa-horizon-client { };
      openshift-installer = callPackage ./openshift-installer { inherit buildGoApplication; };
      smarter-device-manager = callPackage ./smarter-device-manager { inherit buildGoApplication; };
      upjet-provider-cloudflare = callPackage ./upjet-provider-cloudflare { inherit buildUpjetProvider; };
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
          upjet-provider-cloudflare
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
