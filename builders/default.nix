{
  perSystem =
    { inputs', ... }:
    let
      inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication;

      buildUpjetProviderRepo = ./upjet/provider-repo.nix;

      buildUpjetProvider =
        args: import ./upjet/provider.nix ({ inherit buildGoApplication buildUpjetProviderRepo; } // args);
    in
    {
      legacyPackages = {
        inherit buildUpjetProviderRepo buildUpjetProvider;
      };
    };
}
