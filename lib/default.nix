let
  mkBuf = pkgs: pkgs.callPackage ./buf { };
  mkGo = pkgs: pkgs.callPackage ./go { };
  mkKubeVip = pkgs: pkgs.callPackage ./kube-vip { };
  mkUpjet = pkgs: pkgs.callPackage ./upjet { };

  mkLib =
    pkgs:
    pkgs.lib.extend (
      _: prev: {
        buf = mkBuf pkgs;
        go = mkGo pkgs;
        kubeVip = mkKubeVip pkgs;
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
            inherit (self'.packages) kube-vip;
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
        upjetTools = lib.upjet;
      };
    };
}
