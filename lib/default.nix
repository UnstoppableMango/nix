let
  mkGo = pkgs: pkgs.callPackage ./go { };

  mkLib =
    pkgs:
    pkgs.lib.extend (
      _: prev: {
        go = mkGo pkgs;
        maintainers = prev.maintainers // (import ./maintainers.nix);
      }
    );
in
{
  perSystem =
    { pkgs, ... }:
    let
      lib = mkLib pkgs;
    in
    {
      legacyPackages = {
        inherit lib;
        mangoTools = lib.go;
      };
    };
}
