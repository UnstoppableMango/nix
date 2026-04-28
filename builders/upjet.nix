{
  crdRootGroup ? "crossplane.io",
  fetchFromGitHub,
  lib,
  providerName,
  providerNameLower ? lib.strings.toLower providerName,
  organizationName,
  stdenv,
  version,
}:
stdenv.mkDerivation {
  pname = "upjet-provider-${providerNameLower}";
  inherit version;

  src = fetchFromGitHub {
    owner = "crossplane";
    repo = "upjet-provider-template";
    rev = "96440083ef6ed070d9413436a9d6a40000d6773f";
    hash = "sha256-OhXPzgzaXmaWsgFow1wocyMoFY4Apb7Lj552I248l50=";
    fetchSubmodules = true;
  };

  PROVIDER_NAME_LOWER = providerNameLower;
  PROVIDER_NAME_NORMAL = providerName;
  ORGANIZATION_NAME = organizationName;
  CRD_ROOT_GROUP = crdRootGroup;

  preConfigure = ''
    substituteInPlace hack/prepare.sh \
      --replace-fail "git grep" "grep"
    patchShebangs hack/prepare.sh
  '';

  configurePhase = ''
    runHook preConfigure
    hack/prepare.sh
  '';

  buildPhase = ''
    echo 'Got here'
  '';

  installPhase = ''
    cp -r . $out
  '';

  # installPhase = ''
  #   cp -r $src $out
  # '';
}
