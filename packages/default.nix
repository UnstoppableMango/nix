{
  imports = [
    ./kube-vip
    ./dotnet.nix
    ./go.nix
    ./upjet.nix
  ];

  perSystem =
    { pkgs, lib, ... }:
    let
      callPackage = lib.callPackageWith (packages // pkgs);

      packages = {
        omnissa-horizon-client = callPackage ./omnissa-horizon-client { };
      };
    in
    {
      packages = {
        inherit (packages) omnissa-horizon-client;
      };

      legacyPackages = {
        inherit (packages) omnissa-horizon-client;
      };
    };
}
