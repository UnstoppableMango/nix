{ nix2container, kube-vip, ... }:
nix2container.buildImage {
  name = "kube-vip";
  tag = "latest";
  copyToRoot = [ kube-vip ];
}
