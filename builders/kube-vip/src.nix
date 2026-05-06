{
  fetchFromGitHub,
  rev ? "1.1.2",
  hash ? "sha256-vH9fiFInTu2NnC2jLrZUpjaxUxcQuwgvCyl9jlU+UqU=",
}:
fetchFromGitHub {
  inherit rev hash;
  owner = "kube-vip";
  repo = "kube-vip";
}
