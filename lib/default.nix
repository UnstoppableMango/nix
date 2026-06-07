let
  mkBuf = pkgs: pkgs.callPackage ./buf { };
  mkGo = pkgs: pkgs.callPackage ./go { };
  mkKubeVip = pkgs: pkgs.callPackage ./kube-vip { };
  mkTerraform = pkgs: pkgs.callPackage ./terraform { };
  mkUpjet = pkgs: pkgs.callPackage ./upjet { };

  mkLib =
    pkgs:
    pkgs.lib.extend (
      _: prev: {
        buf = mkBuf pkgs;
        go = mkGo pkgs;
        kubeVip = mkKubeVip pkgs;
        terraform = mkTerraform pkgs;
        upjet = mkUpjet pkgs;
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

        bufTools = lib.buf;
        mangoTools = lib.go;
        kubeVipTools = lib.kubeVip;
        terraformTools = lib.terraform;
        upjetTools = lib.upjet;
      };
    };
}
