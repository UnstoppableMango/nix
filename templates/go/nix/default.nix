{
  buildGoApplication,
  cleanSource,
  ginkgo,
  version,
}:
buildGoApplication {
  pname = "";
  inherit version;

  src = cleanSource ../.;
  modules = ../gomod2nix.toml;

  nativeBuildInputs = [ ginkgo ];

  checkPhase = ''
    ginkgo run ./...
  '';
}
