{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
let
  version = "24.6.1";
in
python3Packages.buildPythonApplication {
  pname = "awxkit";
  inherit version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ansible";
    repo = "awx";
    tag = version;
    hash = "sha256-ByDB3OhUvGPyRQUtMfkQUbSiAeGAli3zyaBtNlNILt4=";
  };

  sourceRoot = "source/awxkit";

  postPatch = ''
    echo "${version}" > VERSION
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    cryptography
    jq
    pyyaml
    requests
    setuptools
    websocket-client
  ];

  meta = with lib; {
    description = "Official command line interface for Ansible AWX";
    homepage = "https://github.com/ansible/awx";
    license = licenses.asl20;
    maintainers = with maintainers; [ UnstoppableMango ];
    mainProgram = "awx";
  };
}
