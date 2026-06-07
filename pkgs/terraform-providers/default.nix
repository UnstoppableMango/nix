{
  lib,
  buildGoApplication,
  fetchFromGitHub,
  mangoTools,
}:

let
  mkProvider = lib.makeOverridable (
    {
      owner,
      repo,
      rev,
      version ? lib.removePrefix "v" rev,
      hash,
      modules,
      spdx ? "UNSET",
      homepage ? "",
      provider-source-address ?
        lib.replaceStrings [ "https://registry" ".io/providers" ] [ "registry" ".io" ]
          homepage,
      ...
    }@attrs:
    assert lib.stringLength provider-source-address > 0;
    let
      src = fetchFromGitHub {
        name = "source-${rev}";
        inherit
          owner
          repo
          rev
          hash
          ;
      };
    in
    buildGoApplication {
      pname = repo;
      inherit version modules src;

      doCheck = false;
      # https://github.com/hashicorp/terraform-provider-scaffolding/blob/a8ac8375a7082befe55b71c8cbb048493dd220c2/.goreleaser.yml
      # goreleaser (used for builds distributed via terraform registry) requires that CGO is disabled
      # https://github.com/NixOS/nixpkgs/blob/8e0bf15ad409d025e84f8e55c5c0ee284c41141c/pkgs/applications/networking/cluster/terraform-providers/default.nix#L51
      CGO_ENABLED = 0;

      ldflags = [
        "-s"
        "-w"
        "-X main.version=${version}"
        "-X main.commit=${rev}"
      ];

      postInstall = ''
        dir=$out/libexec/terraform-providers/${provider-source-address}/${version}/''${GOOS}_''${GOARCH}
        mkdir -p "$dir"
        mv $out/bin/* "$dir/terraform-provider-$(basename ${provider-source-address})_${version}"
        rmdir $out/bin
      '';

      meta = {
        inherit homepage;
        license = lib.getLicenseFromSpdxId spdx;
      };

      passthru = attrs // {
        inherit provider-source-address src;
        update-deps = mangoTools.mkUpdateDeps src;
      };
    }
  );

in
{
  inherit mkProvider;

  marshallford_pfsense = mkProvider {
    owner = "marshallford";
    repo = "terraform-provider-pfsense";
    rev = "v0.22.0";
    hash = "sha256-hGPq3m41DmfvpZgHSYVVH/vqhyU5WrgK3P4d6NBlU6k=";
    modules = ../terraform-provider-pfsense/gomod2nix.toml;
    spdx = "MIT";
    homepage = "https://registry.terraform.io/providers/marshallford/pfsense";
  };
}
