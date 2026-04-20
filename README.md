# Nix Crap

Aggregator of Nix things.
Feel free to consume, but this is primarily for personal use.

## Packages

[aspire-cli](./packages/aspire-cli/default.nix)
[chart-releaser](./packages/chart-releaser/default.nix)
[kubectl-get-all](./packages/kubectl-get-all/default.nix)
[kubectl-get-resources](./packages/kubectl-get-resources/default.nix)
[mmake](./packages/mmake/default.nix)
[openshift-installer](./packages/openshift-installer/default.nix)
[provider-upjet-cloudflare](./packages/provider-upjet-cloudflare/default.nix)

## Crossplane packages

This repo builds `crossplane-contrib/provider-upjet-cloudflare` with Nix and
publishes the resulting controller image and Crossplane package to this repo's
GHCR namespace:

`ghcr.io/unstoppablemango/provider-upjet-cloudflare:<version>`

`ghcr.io/unstoppablemango/provider-upjet-cloudflare-controller:<version>`

Publishing is automated by `.github/workflows/publish-provider-upjet-cloudflare.yml`.
The workflow polls upstream `main`, generates a commit-based tag, builds the
controller image and xpkg from source with Nix, and pushes both artifacts to
GHCR. The flake package itself is a pinned build of the current upstream main
snapshot for local validation.

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
