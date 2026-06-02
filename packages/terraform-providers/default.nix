{
  lib,
  buildGoApplication,
  fetchFromGitHub,
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
    buildGoApplication {
      pname = repo;
      inherit version modules;

      src = fetchFromGitHub {
        name = "source-${rev}";
        inherit
          owner
          repo
          rev
          hash
          ;
      };

      doCheck = false;
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
        inherit provider-source-address;
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
