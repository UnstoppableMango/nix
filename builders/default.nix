{
  perSystem =
    { ... }:
    let
      buildUpjetProviderRepo = ./upjet/provider-repo.nix;
      buildUpjetProvider = ./upjet/provider.nix;
    in
    {
      legacyPackages = {
        inherit buildUpjetProviderRepo buildUpjetProvider;
      };
    };
}
