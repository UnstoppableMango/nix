{
  address,
  extraArgs ? [ ],
  interface,
  kube-vip,
  runCommand,
}:
runCommand "kube-vip-manifest-pod" { nativeBuildInputs = [ kube-vip ]; } ''
  kube-vip manifest pod \
    --interface ${interface} \
    --address ${address} \
    ${toString extraArgs} \
    > $out
''
