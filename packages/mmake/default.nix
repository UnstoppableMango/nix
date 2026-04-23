{
  perSystem =
    { pkgs, lib, ... }:
    let
      version = "1.4.0";
      src = pkgs.fetchFromGitHub {
        owner = "tj";
        repo = "mmake";
        rev = "v${version}";
        hash = "sha256-JPsVfLIl06PJ8Nsfu7ogwrttB1G93HTKbZFqUTSV9O8=";
      };

      updateDeps = pkgs.writeShellScript "update-deps" ''
        dir="$(${pkgs.coreutils}/bin/mktemp -d)"
        trap '${pkgs.coreutils}/bin/rm -rf "$dir"' EXIT
        ${pkgs.gomod2nix}/bin/gomod2nix generate \
          --dir ${src} \
          --outdir "$dir"
        ${pkgs.coreutils}/bin/cat "$dir/gomod2nix.toml"
      '';
    in
    {
      apps.update-mmake-deps = {
        type = "app";
        program = "${updateDeps}";
      };

      packages.mmake = pkgs.buildGoApplication {
        pname = "mmake";
        inherit version src;

        modules = ./gomod2nix.toml;

        checkPhase = ''
          go test -v ./... -skip 'Installer|Github|Universal'
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
