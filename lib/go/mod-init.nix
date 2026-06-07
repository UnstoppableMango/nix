{
  gitMinimal,
  go,
  modulePath,
  name ? "go-mod-init",
  src,
  writeShellApplication,
}:
writeShellApplication {
  inherit name;

  runtimeInputs = [
    go
    gitMinimal
  ];

  text = ''
    dir="$(mktemp -d)"
    cp -r ${src}/. "$dir/"

    git -C "$dir" init --initial-branch=main
    git -C "$dir" add .
    git -C "$dir" commit -m 'init'

    go -C "$dir" mod init '${modulePath}'
    go -C "$dir" mod tidy
    git -C "$dir" add .

    git -C "$dir" diff -p --cached >"$1"
  '';
}
