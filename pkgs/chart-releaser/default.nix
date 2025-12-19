{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.chart-releaser = pkgs.buildGoApplication rec {
        pname = "chart-releaser";
        version = "1.8.1";

        src = pkgs.fetchFromGitHub {
          owner = "helm";
          repo = "chart-releaser";
          rev = "v${version}";
          hash = "sha256-h1czHb/xK+kOEK4TJhMnwnLeVmQm52C8dTUy+fahJ90=";
        };

        modules = ./gomod2nix.toml;

        postPatch = ''
          substituteInPlace pkg/config/config.go \
            --replace "\"/etc/cr\"," "\"$out/etc/cr\","
        '';

        ldflags = [
          "-w"
          "-s"
          "-X github.com/helm/chart-releaser/cr/cmd.Version=${version}"
          "-X github.com/helm/chart-releaser/cr/cmd.GitCommit=${src.rev}"
          "-X github.com/helm/chart-releaser/cr/cmd.BuildDate=19700101-00:00:00"
        ];

        nativeBuildInputs = with pkgs; [
          git
          installShellFiles
          makeWrapper
        ];

        postInstall = ''
          installShellCompletion --cmd cr \
            --bash <($out/bin/cr completion bash) \
            --zsh <($out/bin/cr completion zsh) \
            --fish <($out/bin/cr completion fish) \

          wrapProgram $out/bin/cr --prefix PATH : ${
            lib.makeBinPath [
              pkgs.coreutils
              pkgs.git
              pkgs.kubectl
              pkgs.kubernetes-helm
              pkgs.yamale
              pkgs.yamllint
            ]
          }
        '';

        meta = with lib; {
          description = "Hosting Helm Charts via GitHub Pages and Releases";
          homepage = "https://github.com/helm/chart-releaser";
          license = licenses.asl20;
          maintainers = with maintainers; [ UnstoppableMango ];
          mainProgram = "cr";
        };
      };
    };
}
