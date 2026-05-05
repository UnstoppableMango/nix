{
  callPackage,
  fetchFromGitHub,
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

  kube-vip = callPackage ./main.nix { inherit src version; };
  container = callPackage ./container.nix { inherit kube-vip; };
in
{
  inherit kube-vip container;
}
