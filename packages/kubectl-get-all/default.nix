{
  perSystem =
    { pkgs, lib, ... }:
    let
        version = "1.4.2";
      src = pkgs.fetchFromGitHub {
        owner = "stackitcloud";
        repo = "kubectl-get-all";
        rev = "v${version}";
        hash = "sha256-7KYnWeml3vVxklmw26S44U92Hpvgw9yIQ9wgQGrUb3U=";
      };

      updateDeps = pkgs.writeShellScript "update-deps" ''
        dir="$(mktemp -d)"
        ${pkgs.gomod2nix}/bin/gomod2nix generate \
          --dir ${src} \
          --outdir "$dir"
        ${pkgs.coreutils}/bin/cat "$dir/gomod2nix.toml"
      '';
    in
    {
      apps.update-kubectl-get-all-deps = {
        type = "app";
        program = "${updateDeps}";
      };

      packages.kubectl-get-all = pkgs.buildGoApplication rec {
        pname = "kubectl-get-all";
        inherit version src;

        modules = ./gomod2nix.toml;

        ldflags = [
          "-w"
          "-s"
          "-X github.com/stackitcloud/kubectl-get-all/internal/version.Version=${version}"
        ];

        meta = with lib; {
          description = "Like `kubectl get all`, but get really all resources";
          homepage = "https://github.com/stackitcloud/kubectl-get-all";
          license = licenses.asl20;
          maintainers = with maintainers; [ UnstoppableMango ];
          mainProgram = "kubectl-get-all";
        };
      };
    };
}
