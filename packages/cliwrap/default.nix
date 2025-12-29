{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.cliwrap = pkgs.buildDotnetModule {
        pname = "cliwrap";
        version = "3.10.0";

        projectFile = "CliWrap/CliWrap.csproj";
        nugetDeps = ./deps.json;

        src = pkgs.fetchFromGitHub {
          owner = "Tyrrrz";
          repo = "CliWrap";
          rev = "3.10"; # Note this can differ slightly from version
          sha256 = "sha256-a9fcRdnZWJfrDfoA/5QXv9qPn4W86oM522zEsJQiCRQ=";
        };

        dotnet-sdk = pkgs.dotnetCorePackages.sdk_10_0_1xx;

        packNupkg = true;

        meta = with lib; {
          description = "Library for interacting with command-line interfaces";
          homepage = "https://github.com/Tyrrrz/CliWrap";
          license = licenses.mit;
          maintainers = with maintainers; [ UnstoppableMango ];
        };
      };
    };
}
