{
  perSystem =
    { self', pkgs, ... }:
    let
      inherit (self'.legacyPackages) bufTools;
      inherit (pkgs) fetchFromGitHub;
    in
    {
      packages.apis = bufTools.build {
        name = "apis";
        src = fetchFromGitHub {
          owner = "unmango";
          repo = "apis";
          rev = "main";
          sha256 = "sha256-6JuK71ZdQsK9/Sxt2qhFskkIgBPThyMiUpouPSZgBhg=";
        };
      };
    };
}
