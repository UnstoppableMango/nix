{
  buildGoApplication,
  callPackage,
  kubeVipTools,
  ...
}:
let
  version = "1.1.2";
  src = callPackage kubeVipTools.src {
    rev = "v${version}";
    hash = "sha256-vH9fiFInTu2NnC2jLrZUpjaxUxcQuwgvCyl9jlU+UqU=";
  };
in
{
  kube-vip = callPackage ./main.nix {
    inherit
      src
      version
      buildGoApplication
      kubeVipTools
      ;
  };
}
