# Nix Crap

[![Hercules CI](https://hercules-ci.com/api/v1/site/github/account/UnstoppableMango/project/nix/badge)](https://hercules-ci.com/github/UnstoppableMango/nix)

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

- [omnissa-horizon-client](./pkgs/omnissa-horizon-client/default.nix)
- [smarter-device-manager](./pkgs/smarter-device-manager/default.nix)

## Builders

Nix builder functions.

- [go](./builders/go/default.nix) `mangoTools`

## CI

`flakeModules.ci` gives a flake its Hercules CI jobs and the `renovate-fixup` app.

```nix
{
  imports = [ inputs.mangonix.flakeModules.ci ];

  ci = {
    # Broken upstream: https://example.com/tracking-issue
    exclude.packages = [ "broken" ];
    # Built nightly, not on push.
    nightly.packages = [ "slow" ];
  };

  perSystem =
    { pkgs, ... }:
    {
      ci.fixup = {
        runtimeInputs = [ pkgs.gnumake ];
        steps = [ "make generate" ];
      };
    };
}
```

### How to join CI

Every template already does the first three steps.
The design is the [Nix CI spec](https://github.com/UnstoppableMango/nixos/blob/main/docs/nix-ci.md#joining-ci).

1. Add this flake as the `mangonix` input and import `inputs.mangonix.flakeModules.ci`, as above.
   List the commands that refresh generated files after an update in `perSystem.ci.fixup.steps`.
2. Add `.github/workflows/ci.yml` calling `unmango/ci`'s `nix-ci.yml`, pinned by commit, with a `required` job that needs every job that should block a merge.
   [unmango/ci's README](https://github.com/unmango/ci#nix-ciyml) has the file; `templates/default/.github/workflows/ci.yml` is a copy.
3. Extend `github>UnstoppableMango/renovate-config:nix` after the default preset in `.github/renovate.json`, and `:nix-deploys` after it when `main` deploys.
4. Add the repo's ruleset with `required` as its only check: a `PublicRepo` with `requiredGate` in [unmango/scm](https://github.com/unmango/scm) for unmango, or an entry in [UnstoppableMango/vcs](https://github.com/UnstoppableMango/vcs) for UnstoppableMango.
5. Set the `CACHIX_AUTH_TOKEN` secret, which only pushes to `main` use.

Private repos, repos on other accounts, and repos without a flake skip Hercules: they pass `linux: true` to `nix-ci.yml`, and the hosted job builds Linux instead.
A private repo also sets `ci.hercules.enable = false`, since Hercules builds any repo its GitHub App can see, and passes `cachix-push: false`, since the Cachix cache is public.

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
