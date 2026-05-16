{
  perSystem =
    {
      inputs',
      pkgs,
      lib,
      ...
    }:
    let
      inherit (inputs'.nix2container.packages) nix2container;
      callPackage = lib.callPackageWith (packages // pkgs);

      packages = {
        github-runner = callPackage ./github-runner { inherit nix2container; };
      };
    in
    {
      legacyPackages.images = packages;
    };
}
