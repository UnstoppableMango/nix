{
  buf ? pkgs.buf,
  flags ? "",
  output ? "$out",
  pkgs,
  name,
  runCommand,
  src,
  env ? { },
  ...
}:
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  ${buf}/bin/buf build ${src} \
    --output ${output} \
    ${flags}

  runHook postRun
''
