{
  buildGoApplication,
  buildUpjetProviderRepo,
  externalNames ? {},
  pname,
  version,
  ...
}@args:
buildGoApplication {
  inherit pname version;

  src =
    if builtins.hasAttr "src" args then
      builtins.getAttr "src" args
    else
      import buildUpjetProviderRepo ({ inherit pname version; } // args);

  buildPhase = ''
    runHook preBuild
    # cp ${externalNames}
    runHook postBuild
  '';
}
// args
