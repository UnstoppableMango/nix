{
  perSystem =
    { inputs', pkgs, ... }:
    let
      inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication gomod2nix;

      buildUpjetProviderRepo =
        args: pkgs.callPackage ./provider-repo.nix ({ inherit gomod2nix; } // args);

      buildUpjetProvider =
        args:
        pkgs.callPackage ./provider.nix ({ inherit buildGoApplication buildUpjetProviderRepo; } // args);
    in
    {
      legacyPackages = {
        inherit buildUpjetProviderRepo buildUpjetProvider;
      };
    };
}
