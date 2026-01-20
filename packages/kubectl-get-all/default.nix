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
          hash = "sha256-XDd3B95dnhpuG4redqFOysIYEQm3G6+hiE7uqdksok4=";
        };

        modules = ./gomod2nix.toml;

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
