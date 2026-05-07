{
  gomod2nix,
  writeShellScript,
  src,
}:
writeShellScript "update-deps" ''
  dir="$(mktemp -d)"
  trap 'rm -rf "$dir"' EXIT

  ${gomod2nix}/bin/gomod2nix generate \
    --dir ${src} \
    --outdir "$dir"

  cp "$dir/gomod2nix.toml" "$1"
''
