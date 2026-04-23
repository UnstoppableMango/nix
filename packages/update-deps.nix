{ pkgs, src }:

pkgs.writeShellScript "update-deps" ''
  dir="$(${pkgs.coreutils}/bin/mktemp -d)"
  trap '${pkgs.coreutils}/bin/rm -rf "$dir"' EXIT
  ${pkgs.gomod2nix}/bin/gomod2nix generate \
    --dir ${src} \
    --outdir "$dir"
  ${pkgs.coreutils}/bin/cat "$dir/gomod2nix.toml"
''
