# Nix Crap

Aggregator of Nix things.
Feel free to consume, but this is primarily for personal use.

## Packages

Mini nixpkgs.

- [aspire-cli](./packages/aspire-cli/default.nix)
- [chart-releaser](./packages/chart-releaser/default.nix)
- [kube-vip](./packages/kube-vip/default.nix)
- [kubectl-get-all](./packages/kubectl-get-all/default.nix)
- [kubectl-get-resources](./packages/kubectl-get-resources/default.nix)
- [mmake](./packages/mmake/default.nix)
- [openshift-installer](./packages/openshift-installer/default.nix)

### Experimental

- [apis](./packages/apis/default.nix)
- [omnissa-horizon-client](./packages/omnissa-horizon-client/default.nix)
- [smarter-device-manager](./packages/smarter-device-manager/default.nix)
- [upjet-provider-cloudflare](./packages/upjet-provider-cloudflare/default.nix)

## Builders

Nix builder functions.

- [buf](./builders/buf/default.nix)
- [go](./builders/go/default.nix)
- [kube-vip](./builders/kube-vip/default.nix)
- [upjet](./builders/upjet/default.nix)

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
