{
  from ? "",
  input ? "",
  to,
  type,
  buf ? pkgs.buf,
  pkgs,
  name,
  runCommand,
  env ? { },
  ...
}:
runCommand name env ''
  export HOME="$(mktemp -d)"
  ${buf}/bin/buf convert ${input} \
    --type=${type} \
    --from=${from} \
    --to=${to}
''
