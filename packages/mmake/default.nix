{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.mmake = pkgs.buildGoApplication rec {
        pname = "mmake";
        version = "1.4.0";

        src = pkgs.fetchFromGitHub {
          owner = "tj";
          repo = "mmake";
          rev = "v${version}";
          hash = "sha256-JPsVfLIl06PJ8Nsfu7ogwrttB1G93HTKbZFqUTSV9O8=";
        };

        modules = ./gomod2nix.toml;

        checkPhase = ''
          go test -v ./... -skip Installer
        '';

        nativeBuildInputs = with pkgs; [
          makeWrapper
        ];

        postInstall = ''
          wrapProgram $out/bin/mmake --prefix PATH : ${lib.makeBinPath [ pkgs.gnumake ]}
        '';

        meta = with lib; {
          description = "Modern Make";
          homepage = "https://github.com/tj/mmake";
          license = licenses.mit;
          maintainers = with maintainers; [ UnstoppableMango ];
          mainProgram = "mmake";
        };
      };
    };
}
