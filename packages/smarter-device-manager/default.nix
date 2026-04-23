{
  perSystem =
    { pkgs, lib, ... }:
    let
      pname = "smarter-device-manager";
      version = "1.20.12";
      upstreamSrc = pkgs.fetchFromGitHub {
        owner = "smarter-project";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-uACRrhlSzGctl+ZeSIM2QLI4Uwr1uFbh+m5qpg06Ahs=";
      };
    in
    {
      packages.smarter-device-manager = pkgs.buildGoApplication {
        inherit pname version;

        src = pkgs.runCommand "${pname}-${version}-src" { } ''
          mkdir $out
          cp -r ${upstreamSrc}/. $out
          chmod -R u+w $out
          cp ${./go.mod} $out/go.mod
          cp ${./go.sum} $out/go.sum
        '';

        modules = ./gomod2nix.toml;

        nativeBuildInputs = with pkgs; [
          makeWrapper
        ];

        postPatch = ''
          rm -rf vendor
        '';

        postInstall = ''
          install -Dm644 conf.yaml $out/share/${pname}/conf.yaml
          wrapProgram $out/bin/smarter-device-management \
            --add-flags "-config $out/share/${pname}/conf.yaml"
        '';

        meta = with lib; {
          description = "Kubernetes device plugin for exposing host devices to containers";
          homepage = "https://github.com/smarter-project/smarter-device-manager";
          license = licenses.asl20;
          maintainers = with maintainers; [ UnstoppableMango ];
          mainProgram = "smarter-device-management";
          platforms = platforms.linux;
        };
      };
    };
}
