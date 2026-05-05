{
  buildGoApplication,
  callPackage,
  lib,
  src,
  version,
}:
buildGoApplication {
  pname = "kube-vip";
  inherit version src;

  modules = ./gomod2nix.toml;
  subPackages = [ "." ];

  ldflags = [
    "-w"
    "-s"
    "-X github.com/kube-vip/kube-vip/main.Version=${version}"
    "-X github.com/kube-vip/kube-vip/main.Build=${src.rev}"
    "-extldflags -static"
  ];

  passthru.update-deps = callPackage ../update-deps.nix { inherit src; };

  meta = with lib; {
    description = "Kube-VIP: Virtual IP for Kubernetes clusters";
    homepage = "https://github.com/kube-vip/kube-vip";
    license = licenses.asl20;
    maintainers = with maintainers; [ UnstoppableMango ];
    mainProgram = "kube-vip";
  };
}
