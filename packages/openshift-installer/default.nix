{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.openshift-installer = pkgs.buildGoApplication rec {
        pname = "openshift-installer";
        version = "4.23";

        src = pkgs.fetchFromGitHub {
          owner = "openshift";
          repo = "installer";
          rev = "release-${version}";
          hash = "sha256-BA65db5BAWAgxASPY3G+VE1OSgau+I+vQkIkE71IScM=";
        };

        modules = ./gomod2nix.toml;
        subPackages = [ "cmd/openshift-install" ];

        ldflags = [
          "-w"
          "-s"
          "-X github.com/openshift/installer/pkg/version.Raw=${version}"
          "-X github.com/openshift/installer/pkg/version.Commit=${src.rev}"
          "-X github.com/openshift/installer/pkg/version.defaultArch=amd64"
        ];

        # TODO
        doCheck = false;

        meta = with lib; {
          description = "Install an OpenShift Cluster";
          homepage = "https://github.com/openshift/installer";
          license = licenses.asl20;
          maintainers = with maintainers; [ UnstoppableMango ];
          mainProgram = "openshift-install";
        };
      };
    };
}
