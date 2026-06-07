{ pkgs}:
let
  mkBuf =
    { pkgs }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        build = callPackage ./buf/build.nix;
        buildBin = callPackage ./buf/build-bin.nix;
        convert = callPackage ./buf/convert.nix;
        generate = callPackage ./buf/generate.nix;
      };
    in
    packages;

  mkGo =
    { pkgs }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        mkUpdateDeps = src: callPackage ./go/update-deps.nix { inherit src; };
        modInit = src: modulePath: callPackage ./go/mod-init.nix { inherit src modulePath; };
      };
    in
    packages;

  mkKubeVip =
    { pkgs }:
    let
      callPackage = pkgs.lib.callPackageWith (kubeVip // pkgs);

      kubeVip = {
        manifestPod = callPackage ./kube-vip/manifest-pod.nix;
      };
    in
    kubeVip;

  mkUpjet =
    { pkgs }:
    let
      callPackage = pkgs.lib.callPackageWith (packages // pkgs);

      packages = {
        buildProviderRepo = callPackage ./upjet/provider-repo.nix;
        buildProvider = callPackage ./upjet/provider.nix;
      };
    in
    packages;
in
{
  buf = pkgs.callPackage mkBuf { };
  go = pkgs.callPackage mkGo { };
  kubeVip = pkgs.callPackage mkKubeVip { };
  upjet = pkgs.callPackage mkUpjet { };
}
