{
  perSystem =
    { pkgs, lib, ... }:
    let
      version = "0.1.1";
      src = pkgs.fetchFromGitHub {
        owner = "Sandeep-Prajapati";
        repo = "kubectl-get-resources";
        rev = "v${version}";
        hash = "sha256-XDd3B95dnhpuG4redqFOysIYEQm3G6+hiE7uqdksok4=";
      };

      updateDeps = import ../update-deps.nix { inherit pkgs src; };
    in
    {
      apps.update-kubectl-get-resources-deps = {
        type = "app";
        program = "${updateDeps}";
      };

      packages.kubectl-get-resources = pkgs.buildGoApplication {
        pname = "kubectl-get-resources";
        inherit version src;

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
