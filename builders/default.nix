{
  perSystem =
    { ... }:
    let
      buildUpjetProviderRepo = ./upjet/provider-repo.nix;
    in
    {
      legacyPackages = {
        inherit buildUpjetProviderRepo;
      };
    };
}
