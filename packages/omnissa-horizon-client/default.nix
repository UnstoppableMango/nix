{
  perSystem =
    { pkgs, ... }:
    {
      # Overrides the upstream to include horizon-client-next
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/om/omnissa-horizon-client/package.nix#L159
      packages.omnissa-horizon-client = pkgs.callPackage ./build.nix { };
    };
}
