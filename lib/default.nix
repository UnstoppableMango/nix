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
    { pkgs, self', ... }:
    let
      lib = mkLib (
        pkgs.extend (
          _: _: {
            inherit (self'.packages) kube-vip terraform-plugin-codegen-openapi;
          }
        )
      );
    in
    {
      legacyPackages = {
        inherit lib;
        mangoTools = lib.go;
      };
    };
}
