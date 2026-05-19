{
  buildGoApplication,
  fetchFromGitHub,
  gnumake,
  lib,
  makeWrapper,
  mangoTools,
}:
let
  version = "1.4.0";
  src = fetchFromGitHub {
    owner = "tj";
    repo = "mmake";
    rev = "v${version}";
    hash = "sha256-JPsVfLIl06PJ8Nsfu7ogwrttB1G93HTKbZFqUTSV9O8=";
  };
in
buildGoApplication {
  pname = "mmake";
  inherit version src;

  modules = ./gomod2nix.toml;

  checkPhase = ''
    go test -v ./... -skip 'Installer|Github|Universal'
  '';

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/mmake --prefix PATH : ${lib.makeBinPath [ gnumake ]}
  '';

  passthru.update-deps = mangoTools.mkUpdateDeps src;

  meta = with lib; {
    description = "Modern Make";
    homepage = "https://github.com/tj/mmake";
    license = licenses.mit;
    maintainers = with maintainers; [ UnstoppableMango ];
    mainProgram = "mmake";
  };
}
