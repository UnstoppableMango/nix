{
  buildUpjetProviderRepo,
  callPackage,
  externalNames,
  pname,
  stdenv,
  version,
  ...
}@args:
stdenv.mkDerivation {
  inherit pname version;

  src =
    callPackage buildUpjetProviderRepo {
      inherit pname version;
    }
    // args;

  buildPhase = ''
    cp ${externalNames}
  '';
}
