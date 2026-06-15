{
  lib,
  buildDunePackage,
  version,
}:

buildDunePackage {
  pname = "";
  inherit version;

  src = lib.cleanSource ../.;

  meta = {
    description = "";
    homepage = "";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
