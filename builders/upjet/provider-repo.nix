{
  crdRootGroup ? "crossplane.io",
  fetchFromGitHub,
  git,
  lib,
  providerName,
  providerNameLower ? lib.strings.toLower providerName,
  organizationName,
  stdenv,
  terraformProviderSource,
  terraformProviderRepo,
  terraformProviderVersion,
  terraformProviderDownloadName,
  terraformNativeProviderBinary,
  terraformDocsPath,
  version,
}:
stdenv.mkDerivation {
  # https://github.com/crossplane/upjet/blob/main/docs/generating-a-provider.md
  pname = "upjet-provider-${providerNameLower}";
  inherit version;

  src = fetchFromGitHub {
    owner = "crossplane";
    repo = "upjet-provider-template";
    rev = "96440083ef6ed070d9413436a9d6a40000d6773f";
    hash = "sha256-OhXPzgzaXmaWsgFow1wocyMoFY4Apb7Lj552I248l50=";
    fetchSubmodules = true;
  };

  patches = [ ./Makefile.patch ];

  nativeBuildInputs = [ git ];

  PROVIDER_NAME_LOWER = providerNameLower;
  PROVIDER_NAME_NORMAL = providerName;
  ORGANIZATION_NAME = organizationName;
  CRD_ROOT_GROUP = crdRootGroup;

  # This is terrible, but feels less error-prone than translating `git grep` to `grep`
  preConfigure = ''
    git init -b main && git add .
    patchShebangs hack/prepare.sh
  '';

  configurePhase = ''
    runHook preConfigure
    hack/prepare.sh
    runHook postConfigure
  '';

  buildPhase = ''
    substituteInPlace Makefile \
      --subst-var-by 'TERRAFORM_PROVIDER_SOURCE' '${terraformProviderSource}' \
      --subst-var-by 'TERRAFORM_PROVIDER_REPO' '${terraformProviderRepo}' \
      --subst-var-by 'TERRAFORM_PROVIDER_VERSION' '${terraformProviderVersion}' \
      --subst-var-by 'TERRAFORM_PROVIDER_DOWNLOAD_NAME' '${terraformProviderDownloadName}' \
      --subst-var-by 'TERRAFORM_NATIVE_PROVIDER_BINARY' '${terraformNativeProviderBinary}' \
      --subst-var-by 'TERRAFORM_DOCS_PATH' '${terraformDocsPath}'
  '';

  installPhase = ''
    cp -r . $out
  '';
}
