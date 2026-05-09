{
  buf ? pkgs.buf,
  pkgs,
  pname,
  output ? "bin/${pname}.binpb",
  version,
  src,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit pname version;

  buildInputs = [ buf ];

  buildPhase = ''
    runHook preBuild

    buf build ${src} --output $out/${output}

    runHook postBuild
  '';
}
