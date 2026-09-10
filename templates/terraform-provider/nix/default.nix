{
  buildGoApplication,
  lib,
  ginkgo,
  version,
}:
buildGoApplication {
  pname = "terraform-provider-example";
  inherit version;

  src = lib.cleanSource ../.;
  modules = ./gomod2nix.toml;

  nativeCheckInputs = [ ginkgo ];

  checkPhase = ''
    ginkgo run ./...
  '';
}
