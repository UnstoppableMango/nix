{
  go,
  lib,
  path,
  src,
  stdenvNoCC,
  version,
}:
let
  parts = lib.strings.splitString "." version;
  vpath = "${path}/${lib.lists.head parts}";
in
stdenvNoCC.mkDerivation {
  inherit src version;
  name = "mod-edit";

  nativeBuildInputs = [ go ];

  buildPhase = ''
    go mod edit -require ${vpath}@${version}
  '';

  installPhase = ''
    cp -r . $out
  '';
}
