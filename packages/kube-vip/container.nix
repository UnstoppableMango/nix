{
  cacert,
  nix2container,
  kube-vip,
  ...
}:
nix2container.buildImage {
  name = "kube-vip";
  tag = "latest";
  copyToRoot = [ cacert ];

  config = {
    entrypoint = [ "${kube-vip}/bin/kube-vip" ];
  };
}
