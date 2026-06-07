{
  buf ? pkgs.buf,
  flags ? [ ],
  lib,
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
  ${buf}/bin/buf generate ${src} \
    --output "$out" \
    ${lib.escapeShellArgs flags}

  runHook postRun
''
