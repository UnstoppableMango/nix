{
  gitMinimal,
  go,
  modulePath,
  name ? "go-mod-init",
  src,
  writeShellScript,
}:
writeShellScript name ''
  dir="$(mktemp -d)"
  cp -r ${src}/. "$dir/"

  cd "$dir"
  ${gitMinimal}/bin/git init --initial-branch=main --quiet
  ${gitMinimal}/bin/git add .
  ${gitMinimal}/bin/git commit -m 'init' --quiet

  ${go}/bin/go mod init '${modulePath}' >/dev/null 2>&1
  ${go}/bin/go mod tidy >/dev/null 2>&1
  ${go}/bin/go mod vendor
  ${gitMinimal}/bin/git add .

  ${gitMinimal}/bin/git --no-pager diff -p --cached
''
