{
  pkgs,
  src,
  version,
  gomod2nixToml ? null,
  terraformVersion,
  terraformHash,
  terraformProviderVersion,
  terraformProviderHash,
  terraformProviderDownloadName ? "terraform-provider-cloudflare",
  terraformProviderSource ? "cloudflare/cloudflare",
}:
let
  lib = pkgs.lib;
  pname = "provider-upjet-cloudflare";
  controllerPname = "${pname}-controller";
  targetPlatform = "linux_amd64";
  terraformNativeProviderBinary = "${terraformProviderDownloadName}_v${terraformProviderVersion}";
  terraformProviderZip = pkgs.fetchurl {
    url = "https://github.com/cloudflare/${terraformProviderDownloadName}/releases/download/v${terraformProviderVersion}/${terraformProviderDownloadName}_${terraformProviderVersion}_${targetPlatform}.zip";
    hash = terraformProviderHash;
  };
  terraformZip = pkgs.fetchurl {
    url = "https://releases.hashicorp.com/terraform/${terraformVersion}/terraform_${terraformVersion}_${targetPlatform}.zip";
    hash = terraformHash;
  };
  preparedSource = pkgs.runCommand "${pname}-src-${version}" { } ''
    cp -R ${src} "$out"
    chmod -R u+w "$out"
    ${lib.optionalString (gomod2nixToml != null) "cp ${gomod2nixToml} \"$out/gomod2nix.toml\""}
    substituteInPlace "$out/go.mod" --replace-fail 'go 1.26.1' 'go 1.25'
  '';
  xpkgBuilder = pkgs.buildGoModule {
    pname = "build-xpkg";
    version = "0.1.0";
    src = builtins.path {
      path = ../../hack/build-xpkg;
      name = "build-xpkg-src";
    };
    vendorHash = "sha256-0//YxQ/FQOKCXQTLDeJyweRPgbyMo1LwdCzCjFzpUig=";
    doCheck = false;
  };
  controller = pkgs.buildGoApplication {
    pname = controllerPname;
    inherit version;
    src = preparedSource;
    go = pkgs.go_1_25;
    modules = "${preparedSource}/gomod2nix.toml";
    subPackages = [ "cmd/provider" ];
    doCheck = false;
    CGO_ENABLED = 0;
    GOTOOLCHAIN = "local";
    ldflags = [
      "-X github.com/crossplane-contrib/provider-upjet-cloudflare/internal/version.Version=${version}"
    ];
  };
  runtimeRoot =
    pkgs.runCommand "${controllerPname}-root-${version}"
      {
        nativeBuildInputs = [ pkgs.unzip ];
      }
      ''
        plugin_dir="$out/terraform/provider-mirror/registry.terraform.io/${terraformProviderSource}/${terraformProviderVersion}/${targetPlatform}"

        mkdir -p "$out/bin" "$plugin_dir" "$out/terraform"
        cp ${controller}/bin/provider "$out/bin/provider"

        unzip -j ${terraformZip} terraform -d "$out/bin"
        unzip -j ${terraformProviderZip} ${terraformNativeProviderBinary} -d "$plugin_dir"
        chmod +x "$out/bin/terraform" "$plugin_dir/${terraformNativeProviderBinary}"

        cp ${./terraformrc.hcl} "$out/terraform/.terraformrc"
      '';
  controllerImage = pkgs.dockerTools.buildLayeredImage {
    name = controllerPname;
    tag = version;
    created = "1970-01-01T00:00:01Z";
    contents = [
      pkgs.cacert
      runtimeRoot
    ];
    config = {
      User = "65532";
      Env = [
        "PLUGIN_DIR=/terraform/provider-mirror/registry.terraform.io/${terraformProviderSource}/${terraformProviderVersion}/${targetPlatform}"
        "TF_CLI_CONFIG_FILE=/terraform/.terraformrc"
        "TF_FORK=0"
        "TERRAFORM_VERSION=${terraformVersion}"
        "TERRAFORM_PROVIDER_SOURCE=${terraformProviderSource}"
        "TERRAFORM_PROVIDER_VERSION=${terraformProviderVersion}"
        "TERRAFORM_NATIVE_PROVIDER_PATH=/terraform/provider-mirror/registry.terraform.io/${terraformProviderSource}/${terraformProviderVersion}/${targetPlatform}/${terraformNativeProviderBinary}"
      ];
      Entrypoint = [ "/bin/provider" ];
      ExposedPorts = {
        "8080/tcp" = { };
      };
    };
  };
  package =
    pkgs.runCommand "${pname}-${version}.tar"
      {
        nativeBuildInputs = [
          pkgs.gzip
          xpkgBuilder
        ];
      }
      ''
        gzip -cd ${controllerImage} > controller.tar
        build-xpkg \
          --base-tar controller.tar \
          --package-dir ${preparedSource}/package \
          --output "$out"
      '';
in
{
  inherit
    controller
    controllerImage
    package
    preparedSource
    ;
}
