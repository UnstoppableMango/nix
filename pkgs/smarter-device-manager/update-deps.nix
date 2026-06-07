{ pkgs, src }:

pkgs.writeShellScript "update-smarter-device-manager-deps" ''
  dir="$(${pkgs.coreutils}/bin/mktemp -d)"
  ${pkgs.coreutils}/bin/cp -r ${src}/. "$dir/"

  ${pkgs.go}/bin/go -C "$dir" mod init arm.com/smarter-device-management
  ${pkgs.go}/bin/go -C "$dir" mod tidy

  ${pkgs.gomod2nix}/bin/gomod2nix generate --dir "$dir" --outdir "$dir"
  ${pkgs.coreutils}/bin/cp "$dir/gomod2nix.toml" "$1"
''
