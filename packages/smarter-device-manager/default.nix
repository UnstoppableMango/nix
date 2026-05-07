{
  buildGoApplication,
  callPackage,
  fetchFromGitHub,
  lib,
  makeWrapper,
  mangoTools,
}:
let
  pname = "smarter-device-manager";
  version = "1.20.12";
  src = fetchFromGitHub {
    owner = "smarter-project";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-uACRrhlSzGctl+ZeSIM2QLI4Uwr1uFbh+m5qpg06Ahs=";
  };
in
buildGoApplication {
  inherit pname version;

  # src = modded;
  modules = ./gomod2nix.toml;
  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    install -Dm644 conf.yaml $out/share/${pname}/conf.yaml
    wrapProgram $out/bin/smarter-device-management \
      --add-flags "-config $out/share/${pname}/conf.yaml"
  '';

  passthru.go-mod-patch = mangoTools.modInit src "arm.com/smarter-device-management";
  passthru.update-deps = callPackage ./update-deps.nix { inherit src; };

  meta = with lib; {
    description = "Kubernetes device plugin for exposing host devices to containers";
    homepage = "https://github.com/smarter-project/smarter-device-manager";
    license = licenses.asl20;
    maintainers = with maintainers; [ UnstoppableMango ];
    mainProgram = "smarter-device-management";
    platforms = platforms.linux;
  };
}
