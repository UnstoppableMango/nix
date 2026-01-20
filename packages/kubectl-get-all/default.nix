{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.kubectl-get-all = pkgs.buildGoApplication rec {
        pname = "kubectl-get-all";
        version = "1.4.2";

        src = pkgs.fetchFromGitHub {
          owner = "stackitcloud";
          repo = "kubectl-get-all";
          rev = "v${version}";
          hash = "sha256-7KYnWeml3vVxklmw26S44U92Hpvgw9yIQ9wgQGrUb3U=";
        };

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
