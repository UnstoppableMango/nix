{
  address,
  interface,
  kubeVipTools,
  writeShellScriptBin,
}:
let
  manifest = kubeVipTools.manifestPod {
    inherit address interface;
  };
in
writeShellScriptBin "kube-vip-manifest" ''
  cat '${manifest}'
''
