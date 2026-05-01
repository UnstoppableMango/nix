{
  perSystem =
    { inputs', pkgs, ... }:
    let
      inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication gomod2nix;

      buildUpjetProviderRepo =
        args:
        pkgs.callPackage ./upjet/provider-repo.nix (
          {
            inherit gomod2nix;
            inherit (pkgs) coreutils writeShellApplication;
          }
          // args
        );

      buildUpjetProvider =
        args:
        pkgs.callPackage ./upjet/provider.nix (
          { inherit buildGoApplication buildUpjetProviderRepo; } // args
        );
    in
    {
      legacyPackages = {
        inherit buildUpjetProviderRepo buildUpjetProvider;
      };
    };
}
