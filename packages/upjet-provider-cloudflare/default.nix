{
  buildUpjetProvider,
  lib,
  ...
}:
let
  pname = "upjet-provider-cloudflare";
  version = "0.0.1";
in
buildUpjetProvider {
  inherit pname version;

  organizationName = "cloudflare";
  providerName = "cloudflare";
  terraformProviderSource = "cloudflare/cloudflare";
  terraformProviderRepo = "https://github.com/cloudflare/terraform-provider-cloudflare";
  terraformProviderVersion = "5.19.0";

  modules = ./gomod2nix.toml;

  meta = with lib; {
    description = "TODO";
    homepage = "https://github.com/UnstoppableMango/nix";
    license = licenses.asl20;
    maintainers = with maintainers; [ UnstoppableMango ];
    mainProgram = "upjet-provider-cloudflare";
    platforms = platforms.linux;
  };
}
