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
