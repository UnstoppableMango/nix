{ pkgs, src }:

pkgs.writeShellScript "update-smarter-device-manager-deps" ''
  set -euo pipefail

  reporoot="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
  outdir="$reporoot/packages/smarter-device-manager"

  workdir="$(${pkgs.coreutils}/bin/mktemp -d)"
  trap '${pkgs.coreutils}/bin/rm -rf "$workdir"' EXIT

  ${pkgs.coreutils}/bin/cp -r ${src}/. "$workdir/"
  ${pkgs.coreutils}/bin/chmod -R u+w "$workdir"

  cd "$workdir"
  ${pkgs.go}/bin/go mod init arm.com/smarter-device-management
  ${pkgs.go}/bin/go mod tidy

  ${pkgs.gomod2nix}/bin/gomod2nix generate --dir "$workdir" --outdir "$workdir"

  ${pkgs.coreutils}/bin/cp go.mod go.sum gomod2nix.toml "$outdir/"
  echo "Updated $outdir/{go.mod,go.sum,gomod2nix.toml}" >&2
''
