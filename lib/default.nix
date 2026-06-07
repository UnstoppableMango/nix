{ self, ... }:
{
  flake.mkLib = import ./lib.nix;

  perSystem =
    { self', pkgs, ... }:
    let
      lib = pkgs.lib.callPackageWith self.mkLib {
        inherit (self'.legacyPackages) kube-vip mangoTools;
        inherit pkgs;
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
