# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

Personal Nix flake repository that aggregates various Nix packages and tools. Uses **flake-parts** for modular flake configuration and **gomod2nix** for Go-based packages.

## Commands

```bash
nix develop          # Enter dev shell (provides: gomod2nix, nil, nixfmt, nix-update, nurl, watchexec)
nix fmt              # Format all Nix files with nixfmt
nix flake check      # Validate flake and build all outputs
nix flake check --all-systems  # Check across all supported systems (also: make check)
nix build .#<name>   # Build a specific package
make build           # Build all Go packages
make update          # Update flake.lock (nix flake update)
make deps            # Regenerate all dependency files (gomod2nix.toml, deps.json, manifest.json)
make update-provider/<name>  # Update a specific terraform provider
```

To regenerate `gomod2nix.toml` for a Go package (e.g., after version bump):
```bash
make pkgs/<name>/gomod2nix.toml
```
This uses a nix-built `update-deps` script to fetch the upstream `go.mod` and run `gomod2nix generate`.

## Architecture

### Flake structure

`flake.nix` uses flake-parts and imports two top-level modules:
- `./lib` — library extensions (custom `lib.go` helpers, custom maintainers)
- `./pkgs` — all package definitions

`pkgs/default.nix` defines all packages directly and imports submodules (`./kube-vip`, `./images`). New packages are added here or to the appropriate submodule, not directly to `flake.nix`.

A subset of packages is exposed via `overlayAttrs` so other flakes can consume them as an overlay:
awxkit, chart-releaser, kubectl-get-all, kubectl-get-resources, kubectl-slice, mmake, openshift-installer.

### Packages

**Go packages** (`pkgs/default.nix` and `pkgs/kube-vip/`): chart-releaser, kube-vip, kubectl-get-all, kubectl-get-resources, kubectl-slice, mmake, openshift-installer, smarter-device-manager, terraform-plugin-codegen-openapi, terraform-provider-pfsense. All use `buildGoApplication` from gomod2nix and require a `gomod2nix.toml`.

**Dotnet packages** (`pkgs/aspire-cli/`): aspire-cli. Uses `buildDotnetModule`; deps regenerated via `make pkgs/aspire-cli/deps.json` (runs the package's nix-built `fetch-deps` script).

**Python packages** (`pkgs/default.nix`): awxkit.

**Other packages** (`pkgs/default.nix`): omnissa-horizon-client (unfree VMware Horizon client).

**Terraform provider collection** (`pkgs/terraform-providers/`): terraform-providers. Defines `mkProvider` (wraps `buildGoApplication` with standard provider install layout) and exposes named providers (e.g. `marshallford_pfsense`). Exposed via `legacyPackages` only, not `packages`. Update a provider with `make update-provider/<name>`.

**Container images** (`pkgs/images/`): github-runner, hercules-ci-agent. Use nix2container; manifests regenerated via `make pkgs/images/<name>/manifest.json`.

### Lib

`lib/` is a flake-parts module that extends `pkgs.lib` and exposes helpers via `legacyPackages`:
- **`lib.go`** (`lib/go/`) — Go helpers: `mkUpdateDeps src` (generates `gomod2nix.toml`), `modInit src modulePath` (initializes a Go module and produces a patch)
- **`lib.maintainers`** (`lib/maintainers.nix`) — custom maintainer entries merged into nixpkgs maintainers
- **`mangoTools`** — alias for `lib.go`, available as `self'.legacyPackages.mangoTools` in perSystem modules

### Templates

`templates/default/` and `templates/go/` provide starter flakes via `nix flake init -t github:UnstoppableMango/nix#<template>`.

## Adding a new package

1. Create `pkgs/<name>/default.nix` following existing package patterns
2. Add the package to `pkgs/default.nix` (or the appropriate submodule for `./kube-vip`, `./images`)
3. For Go packages: add the package name to `GO_PKGS` in the Makefile
4. Optionally add to `overlayAttrs` in `flake.nix` for external consumption via overlay

## Key conventions

- Format with `nix fmt` before committing
- Follow nixpkgs conventions for package meta (description, homepage, license, maintainers)
- Use `inputs.<input>.follows = "nixpkgs"` to pin transitive inputs
- Avoid IFD (Import From Derivation) for build reproducibility
- CI runs `nix flake check` and builds all packages except aspire-cli
