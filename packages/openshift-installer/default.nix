{
  perSystem =
    { pkgs, lib, ... }:
    let
      version = "4.23";
      src = pkgs.fetchFromGitHub {
        owner = "openshift";
        repo = "installer";
        rev = "release-${version}";
        hash = "sha256-VYjmhmbUt6IXUA+pwzfESTp/7hqWwukp7sE6wF5Ouus=";
      };

      updateDeps = pkgs.writeShellScript "update-deps" ''
        dir="$(${pkgs.coreutils}/bin/mktemp -d)"
        trap '${pkgs.coreutils}/bin/rm -rf "$dir"' EXIT
        ${pkgs.gomod2nix}/bin/gomod2nix generate \
          --dir ${src} \
          --outdir "$dir"
        ${pkgs.coreutils}/bin/cat "$dir/gomod2nix.toml"
      '';
    in
    {
      apps.update-openshift-installer-deps = {
        type = "app";
        program = "${updateDeps}";
      };

      packages.openshift-installer = pkgs.buildGoApplication {
        pname = "openshift-installer";
        inherit version src;

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
