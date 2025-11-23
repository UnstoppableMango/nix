{
  buildGoModule,
  coreutils,
  fetchFromGitHub,
  git,
  installShellFiles,
  kubectl,
  kubernetes-helm,
  lib,
  makeWrapper,
  yamale,
  yamllint,
}:

buildGoModule rec {
  pname = "chart-releaser";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "helm";
    repo = "chart-releaser";
    rev = "v${version}";
    hash = "sha256-wdUUo19bFf3ov+Rd+JV6CtbH9TWGC73lWRrNLOfNGR8=";
  };

  vendorHash = "sha256-29rGyStJsnhJiO01DIFf/ROaYsXGg3YRJatdzC6A7JU=";

  # postPatch = ''
  #   substituteInPlace pkg/config/config.go \
  #     --replace "\"/etc/ct\"," "\"$out/etc/ct\","
  # '';

  # ldflags = [
  #   "-w"
  #   "-s"
  #   "-X github.com/helm/chart-testing/v3/ct/cmd.Version=${version}"
  #   "-X github.com/helm/chart-testing/v3/ct/cmd.GitCommit=${src.rev}"
  #   "-X github.com/helm/chart-testing/v3/ct/cmd.BuildDate=19700101-00:00:00"
  # ];

  # nativeBuildInputs = [
  #   installShellFiles
  #   makeWrapper
  # ];

  # postInstall = ''
  #   install -Dm644 -t $out/etc/ct etc/chart_schema.yaml
  #   install -Dm644 -t $out/etc/ct etc/lintconf.yaml

  #   installShellCompletion --cmd ct \
  #     --bash <($out/bin/ct completion bash) \
  #     --zsh <($out/bin/ct completion zsh) \
  #     --fish <($out/bin/ct completion fish) \

  #   wrapProgram $out/bin/ct --prefix PATH : ${
  #     lib.makeBinPath [
  #       coreutils
  #       git
  #       kubectl
  #       kubernetes-helm
  #       yamale
  #       yamllint
  #     ]
  #   }
  # '';

  meta = with lib; {
    description = "Hosting Helm Charts via GitHub Pages and Releases";
    homepage = "https://github.com/helm/chart-releaser";
    license = licenses.asl20;
    maintainers = with maintainers; [ UnstoppableMango ];
    mainProgram = "cr";
  };
}
