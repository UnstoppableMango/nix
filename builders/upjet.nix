{
  fetchFromGitHub,
  stdenv,
  providerName,
  version,
}:
stdenv.mkDerivation {
  pname = "upjet-provider-${providerName}";
  inherit version;

  src = fetchFromGitHub {
    owner = "crossplane";
    repo = "upjet-provider-template";
    rev = "96440083ef6ed070d9413436a9d6a40000d6773f";
    hash = "sha256-OhXPzgzaXmaWsgFow1wocyMoFY4Apb7Lj552I248l50=";
    fetchSubmodules = true;
  };

  # preparePhase = ''
  #   ./hack/prepare.sh
  # '';

  installPhase = ''
    cp -r $src $out
  '';
}
