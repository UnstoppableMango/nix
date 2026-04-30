{
  buildGoApplication,
  buildUpjetProviderRepo,
  externalNames ? { },
  modules,
  pname,
  version,
  ...
}@attrs:
let
  src = buildUpjetProviderRepo ({ inherit pname version; } // attrs);
in
buildGoApplication {
  inherit
    pname
    version
    modules
    src
    ;

  inherit (src) passthru;

  # buildPhase = ''
  #   runHook preBuild
  #   runHook postBuild
  # '';
}
