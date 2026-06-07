let
  mkLib = pkgs: import ./lib.nix { inherit pkgs; };
in
{
  flake = { inherit mkLib; };

  perSystem =
    { self', pkgs, ... }:
    let
      lib = pkgs.callPackage mkLib {
        inherit (self'.legacyPackages) lib kube-vip mangoTools;
      };
    in
    {
      legacyPackages = {
        inherit lib;

        bufTools = lib.buf;
        mangoTools = lib.go;
        kubeVipTools = lib.kubeVip;
        upjetTools = lib.upjet;
      };
    };
}
