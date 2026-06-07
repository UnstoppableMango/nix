{
  address,
  extraArgs ? [ ],
  interface,
  kube-vip,
  runCommand,
}:
runCommand "kube-vip-manifest-pod" { } ''
  ${kube-vip}/bin/kube-vip manifest pod \
    --interface ${interface} \
    --address ${address} \
    ${toString extraArgs} \
    > $out
''
