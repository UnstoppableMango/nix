{
  nix2container,
  ...
}:
nix2container.buildImage {
  name = "github-runner";
  fromImage = nix2container.pullImage {
    imageName = "ghcr.io/actions/actions-runner";
    imageDigest = "sha256:b6614fce332517f74d0a76e7c762fb08e4f2ff13dcf333183397c8a5725b6e8e";
    arch = "amd64";
    sha256 = "sha256-7MbqeZv3gKRdWCecf7816vKqBZIPgrX2d++uJmiY9Ks=";
  };

  config = {
    user = "runner";
    entrypoint = [ "/home/runner/run.sh" ];
  };
}
