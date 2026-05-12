{
  imports = [
    ./apis
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
        awxkit = callPackage ./awxkit { };
        omnissa-horizon-client = callPackage ./omnissa-horizon-client { };
      };
    in
    {
      packages = {
        inherit (packages) awxkit omnissa-horizon-client;
      };

      legacyPackages = {
        inherit (packages) awxkit omnissa-horizon-client;
      };
    };
}
