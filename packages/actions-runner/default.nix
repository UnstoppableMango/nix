{
  perSystem =
    { pkgs, system, ... }:
    let
      # Map from NixOS system names to runtime identifiers used by .NET
      # https://learn.microsoft.com/en-us/dotnet/core/rid-catalog
      rids = {
        x86_64-linux = "linux-x64";
        aarch64-linux = "linux-arm64";
      };

      rid = rids.${system};

      # https://github.com/actions/runner/blob/main/src/global.json#L3
      dotnet = pkgs.dotnetCorePackages.sdk_8_0;
    in
    {
      packages.actions-runner = pkgs.stdenv.mkDerivation rec {
        pname = "actions-runner";
        version = "2.330.0";

        src = pkgs.fetchFromGitHub {
          owner = "actions";
          repo = "runner";
          tag = "v${version}";
          hash = "sha256-9/W2QYC9iAGVqvO82SsyBXJp0q1irhJq0VSUXPuDCCA=";
        };

        buildInputs = with pkgs; [
          bash
          curl
          dotnet
          git
          powershell
          which
        ];

        buildPhase = ''
          cd src
          sed -i '5,7d;30d' ./dir.proj
          dotnet msbuild -t:Build -p:PackageRuntime="${rid}" -p:BUILDCONFIG="Release" -p:RunnerVersion="${version}" -p:GitInfoCommitHash="TODO" ./dir.proj
        '';
      };
    };
}
