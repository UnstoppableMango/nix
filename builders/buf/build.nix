{
  buf ? pkgs.buf,
  flags ? [ ],
  lib,
  output ? "$out/${pname}.binpb",
  pkgs,
  pname,
  runCommand,
  src,
  version,
  ...
}@attrs:
runCommand "${pname}-${version}" attrs ''
  ${buf}/bin/buf build ${src} --output $out/${output} ${lib.escapeShellArgs flags}
''
