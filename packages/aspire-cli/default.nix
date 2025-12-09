let
  version = "13.0.2";
in
{
  perSystem =
    { pkgs, ... }:
    let
      dotnet = pkgs.dotnetCorePackages.sdk_10_0_1xx;
    in
    {
      packages.aspire-cli = pkgs.buildDotnetModule {
        pname = "aspire-cli";
        inherit version;

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
    };
}
