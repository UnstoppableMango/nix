{
  applyPatches,
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

  gitSrc = fetchFromGitHub {
    owner = "smarter-project";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-uACRrhlSzGctl+ZeSIM2QLI4Uwr1uFbh+m5qpg06Ahs=";
  };

  src = applyPatches {
    patches = [ ./gomod.patch ];
    src = gitSrc;
  };
in
buildGoApplication {
  inherit pname version src;

  modules = ./gomod2nix.toml;
  nativeBuildInputs = [ makeWrapper ];

  # https://github.com/smarter-project/smarter-device-manager/blob/main/Dockerfile#L11-L13
  CGO_LDFLAGS_ALLOW = "-Wl,--unresolved-symbols=ignore-in-object-files";
  CGO_ENABLED = 0;

  ldFlags = [
    "-s"
    "-w"
    "-extdldflags '-static'"
  ];

  subPackages = [ "." ];

  postInstall = ''
    install -Dm644 conf.yaml $out/share/${pname}/conf.yaml
    wrapProgram $out/bin/smarter-device-management \
      --add-flags "-config $out/share/${pname}/conf.yaml"
  '';

  passthru.go-mod-patch = mangoTools.modInit gitSrc "arm.com/smarter-device-management";
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
