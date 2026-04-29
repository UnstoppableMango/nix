{
  buildUpjetProvider,
  lib,
  ...
}:
let
  pname = "upjet-provider-cloudflare";
  version = "0.0.1";
in
buildUpjetProvider {
  inherit pname version;

  modules = ./gomod2nix.toml;
  # passthru.update-deps = callPackage ./update-deps.nix { inherit src; };

  meta = with lib; {
    description = "TODO";
    homepage = "https://github.com/UnstoppableMango/nix";
    license = licenses.asl20;
    maintainers = with maintainers; [ UnstoppableMango ];
    mainProgram = "upjet-provider-cloudflare";
    platforms = platforms.linux;
  };
}
