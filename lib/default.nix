let
  mkBuf = pkgs: pkgs.callPackage ./buf { };
  mkGo = pkgs: pkgs.callPackage ./go { };
  mkKubeVip = pkgs: pkgs.callPackage ./kube-vip { };
  mkUpjet = pkgs: pkgs.callPackage ./upjet { };

  mkLib = pkgs: pkgs.lib.extend (_: prev: {
    buf = mkBuf pkgs;
    go = mkGo pkgs;
    kubeVip = mkKubeVip pkgs;
    upjet = mkUpjet pkgs;
    maintainers = prev.maintainers // (import ./maintainers.nix);
  });
in
{
  flake = { inherit mkLib mkBuf mkGo mkKubeVip mkUpjet; };

  perSystem =
    { pkgs, ... }:
    let
      lib = mkLib pkgs;
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
