{
  perSystem =
    { pkgs, ... }:
    let
      version = "main-6c400cbe5b75";
      src = pkgs.fetchFromGitHub {
        owner = "crossplane-contrib";
        repo = "provider-upjet-cloudflare";
        rev = "6c400cbe5b75ac9668a42d48ba39cade575607fb";
        hash = "sha256-c3LOeZW2pHTrhQTRWib/ldIXMW9Pzu7wpKs6NMY980w=";
      };
      artifacts = import ./artifacts.nix {
        inherit pkgs src version;
        gomod2nixToml = ./gomod2nix.toml;
        terraformVersion = "1.5.7";
        terraformHash = "sha256-wO17wy7lKuJVr5mCyMiKekxhBIXPHVX+6wN+q3X6CCw=";
        terraformProviderVersion = "5.15.0";
        terraformProviderHash = "sha256-63Nl6vxhYMOzBKnOalmOVACi53np4r0nl23yRPefd08=";
      };
    in
    {
      packages = {
        provider-upjet-cloudflare = artifacts.package;
        provider-upjet-cloudflare-controller = artifacts.controllerImage;
      };

      checks.provider-upjet-cloudflare = artifacts.package;
    };
}
