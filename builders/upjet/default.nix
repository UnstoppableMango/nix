{
  perSystem =
    { inputs', pkgs, ... }:
    let
      inherit (inputs'.gomod2nix.legacyPackages) buildGoApplication gomod2nix;
      inherit (pkgs) callPackage;

      buildProviderRepo = args: callPackage ./provider-repo.nix ({ inherit gomod2nix; } // args);

      buildProvider =
        args:
        callPackage ./provider.nix (
          {
            inherit buildGoApplication;
            buildUpjetProviderRepo = buildProviderRepo;
          }
          // args
        );

      upjetTools = {
        inherit buildProviderRepo buildProvider;
      };
    in
    {
      legacyPackages = {
        inherit upjetTools;
        buildUpjetProvider = upjetTools.buildProvider;
        buildUpjetProviderRepo = upjetTools.buildProviderRepo;
      };
    };
}
