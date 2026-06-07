# Nix Crap

Aggregator of Nix things.
Feel free to consume, but this is primarily for personal use.

## Packages

Mini nixpkgs.

- [awxkit](./pkgs/awxkit/default.nix)
- [aspire-cli](./pkgs/aspire-cli/default.nix)
- [chart-releaser](./pkgs/chart-releaser/default.nix)
- [kube-vip](./pkgs/kube-vip/default.nix)
- [kubectl-get-all](./pkgs/kubectl-get-all/default.nix)
- [kubectl-get-resources](./pkgs/kubectl-get-resources/default.nix)
- [mmake](./pkgs/mmake/default.nix)
- [openshift-installer](./pkgs/openshift-installer/default.nix)

### OCI Images

- [github-runner](./pkgs/images/github-runner.nix)

### Experimental

- [apis](./pkgs/apis/default.nix)
- [omnissa-horizon-client](./pkgs/omnissa-horizon-client/default.nix)
- [smarter-device-manager](./pkgs/smarter-device-manager/default.nix)
- [upjet-provider-cloudflare](./pkgs/upjet-provider-cloudflare/default.nix)

## Builders

Nix builder functions.

- [buf](./builders/buf/default.nix) `bufTools`
- [go](./builders/go/default.nix) `mangoTools`
- [kube-vip](./builders/kube-vip/default.nix) `kubeVipTools`
- [upjet](./builders/upjet/default.nix) `upjetTools`

## Usage

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    mangonix = {
      url = "github:UnstoppableMango/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    # ...
  };
}
```

### flake-parts

```nix
# flake-module.nix
{
  perSystem = { inputs', system, ... }:
    let
      # Access the builder package sets
      inherit (inputs'.mangonix.legacyPackages) bufTools mangoTools;

      # Access the builder functions
      inherit (mangoTools) mkUpdateDeps;
    in
    {
      # Consume the overlay
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = with inputs'; [
          mangonix.overlays.default
        ];
      };
    }
}
```
