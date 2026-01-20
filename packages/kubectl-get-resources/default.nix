{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.kubectl-get-resources = pkgs.buildGoApplication rec {
        pname = "kubectl-get-resources";
        version = "0.1.1";

        src = pkgs.fetchFromGitHub {
          owner = "Sandeep-Prajapati";
          repo = "kubectl-get-resources";
          rev = "v${version}";
          hash = "sha256-XDd3B95dnhpuG4redqFOysIYEQm3G6+hiE7uqdksok4=";
        };

        modules = ./gomod2nix.toml;

        meta = with lib; {
          description = "Get Kubernetes resources (cluster or namespace scope) in CSV or YAML with support for multiple filtering flags.";
          homepage = "https://github.com/Sandeep-Prajapati/kubectl-get-resources";
          license = licenses.asl20;
          maintainers = with maintainers; [ UnstoppableMango ];
          mainProgram = "kubectl-get-resources";
        };
      };
    };
}
