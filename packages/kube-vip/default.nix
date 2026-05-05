{
  perSystem =
    { pkgs, ... }:
    let
      version = "1.1.2";
      src = pkgs.fetchFromGitHub {
        owner = "kube-vip";
        repo = "kube-vip";
        rev = "v${version}";
        hash = "sha256-vH9fiFInTu2NnC2jLrZUpjaxUxcQuwgvCyl9jlU+UqU=";
      };

      kube-vip = pkgs.callPackage ./main.nix { inherit src version; };
      container = pkgs.callPackage ./container.nix { inherit kube-vip; };
    in
    {
      legacyPackages.kubeVipPackages = {
        inherit kube-vip container;
      };

      packages = { inherit kube-vip; };
    };
}
