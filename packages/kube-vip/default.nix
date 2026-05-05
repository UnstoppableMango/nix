{
  callPackage,
  fetchFromGitHub,
  stdenvNoCC,
  ...
}:
let
  version = "1.1.2";
  src = fetchFromGitHub {
    owner = "kube-vip";
    repo = "kube-vip";
    rev = "v${version}";
    hash = "sha256-vH9fiFInTu2NnC2jLrZUpjaxUxcQuwgvCyl9jlU+UqU=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "kubeVipPackages";
  inherit version src;

  packages = {
    kube-vip = callPackage ./main.nix {
      inherit src version;
    };
  };
}
