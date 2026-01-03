{
  perSystem =
    { pkgs, ... }:
    let
      dotnet = pkgs.dotnetCorePackages.sdk_10_0_1xx;

      # TODO: System.Resources.MissingManifestResourceException: Could not find the resource "Aspire.Cli.Resources.NewCommandStrings.resources" among the resources "Aspire.Cli.Resources.dotnet-install.sh", "Aspire.Cli.Resources.dotnet-install.ps1" embedded in the assembly "aspire", nor among the resources in any satellite assemblies for the specified culture. Perhaps the resources were embedded with an incorrect name.
      aspire-cli = pkgs.buildDotnetModule rec {
        pname = "aspire-cli";
        version = "13.0.2";

        nativeBuildInputs = with pkgs; [
          gcc
        ];

        src = pkgs.fetchFromGitHub {
          owner = "dotnet";
          repo = "aspire";
          rev = "v${version}";
          hash = "sha256-mCDAwg2+yq3D108lHLxXXYCEWs3yMUitKRImjOfTrDU=";
        };

        dotnet-sdk = dotnet;
        projectFile = "./src/Aspire.Cli/Aspire.Cli.csproj";
        nugetDeps = ./deps.json;
        selfContainedBuild = true;

        meta = with pkgs.lib; {
          description = "A CLI tool for managing Aspire projects";
          homepage = "https://github.com/dotnet/aspire";
          maintainers = with maintainers; [ UnstoppableMango ];
          license = licenses.mit;
          mainProgram = "aspire";
        };
      };
    in
    {
      packages = { inherit aspire-cli; };

      apps.aspire-cli = {
        type = "app";
        meta.description = "A CLI tool for managing Aspire projects";
        program = "${aspire-cli}/bin/aspire";
      };
    };
}
