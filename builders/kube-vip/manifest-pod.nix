{
  address,
  extraArgs ? [ ],
  interface,
  kube-vip,
  runCommand,
  src,
}:
runCommand "kube-vip-manifest-pod"
  {
    # inherit src;
    nativeBuildInputs = [ kube-vip ];
  }
  ''
    kube-vip manifest pod \
      --interface ${interface} \
      --address ${address} \
      ${toString extraArgs} \
      > $out
  ''
