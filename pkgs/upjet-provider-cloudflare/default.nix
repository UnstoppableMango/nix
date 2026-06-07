{ upjetTools, lib }:
let
  pname = "upjet-provider-cloudflare";
  version = "0.0.1";
in
upjetTools.buildProvider {
  inherit pname version;

  organizationName = "cloudflare";
  providerName = "cloudflare";
  terraformProviderSource = "cloudflare/cloudflare";
  terraformProviderRepo = "https://github.com/cloudflare/terraform-provider-cloudflare";
  terraformProviderVersion = "5.19.0";

  modules = ./gomod2nix.toml;

  meta = {
    description = "Upjet-based Cloudflare provider generated from the Terraform Cloudflare provider";
    homepage = "https://github.com/UnstoppableMango/nix";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ UnstoppableMango ];
    mainProgram = "upjet-provider-cloudflare";
    platforms = lib.platforms.linux;
  };
}
