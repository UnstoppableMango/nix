{ self, ... }:
{
  flake.lib = {
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
          inherit (pkgs) buildGoApplication gomod2nix;
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
          inherit (pkgs) kube-vip;
          manifestPod = callPackage ./kube-vip/manifest-pod.nix;
        };
      in
      kubeVip;

    mkUpjet =
      { pkgs }:
      let
        callPackage = pkgs.lib.callPackageWith (packages // pkgs);

        packages = {
          inherit (pkgs) mangoTools;
          buildGoApplication = pkgs.buildGoApplication;
          buildProviderRepo = callPackage ./upjet/provider-repo.nix;
          buildProvider = callPackage ./upjet/provider.nix;
        };
      in
      packages;

    mkLib =
      { pkgs, kube-vip }:
      let
        localPkgs = pkgs // {
          inherit kube-vip;
          mangoTools = packages.go;
        };
        callPackage = pkgs.lib.callPackageWith (packages // localPkgs);

        packages = {
          buf = callPackage self.lib.mkBuf { };
          go = callPackage self.lib.mkGo { };
          kubeVip = callPackage self.lib.mkKubeVip { };
          upjet = callPackage self.lib.mkUpjet { };
        };
      in
      packages;
  };

  perSystem =
    { self', pkgs, ... }:
    let
      localPkgs = pkgs // {
        kube-vip = self'.legacyPackages.kube-vip;
        mangoTools = self'.legacyPackages.mangoTools;
      };
    in
    {
      legacyPackages.lib = self.lib.mkLib {
        inherit pkgs;
        kube-vip = self'.legacyPackages.kube-vip;
      };
      legacyPackages.bufTools = self.lib.mkBuf { inherit pkgs; };
      legacyPackages.mangoTools = self.lib.mkGo { inherit pkgs; };
      legacyPackages.kubeVipTools = self.lib.mkKubeVip { pkgs = localPkgs; };
      legacyPackages.upjetTools = self.lib.mkUpjet { pkgs = localPkgs; };
    };
}
