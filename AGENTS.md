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
- `./builders` — reusable builder functions (bufTools, mangoTools, kubeVipTools, upjetTools)
- `./pkgs` — all package definitions

`pkgs/default.nix` defines all packages directly and imports submodules (`./apis`, `./kube-vip`, `./images`). New packages are added here or to the appropriate submodule, not directly to `flake.nix`.

A subset of packages is exposed via `overlayAttrs` so other flakes can consume them as an overlay:
awxkit, chart-releaser, kubectl-get-all, kubectl-get-resources, kubectl-slice, mmake, openshift-installer.

### Packages

**Go packages** (`pkgs/default.nix` and `pkgs/kube-vip/`): chart-releaser, kube-vip, kubectl-get-all, kubectl-get-resources, kubectl-slice, mmake, openshift-installer, smarter-device-manager, terraform-plugin-codegen-openapi, terraform-provider-pfsense, upjet-provider-cloudflare. All use `buildGoApplication` from gomod2nix and require a `gomod2nix.toml`.

**Dotnet packages** (`pkgs/aspire-cli/`): aspire-cli. Uses `buildDotnetModule`; deps regenerated via `make pkgs/aspire-cli/deps.json` (runs the package's nix-built `fetch-deps` script).

**Python packages** (`pkgs/default.nix`): awxkit.

**Other packages** (`pkgs/default.nix`): omnissa-horizon-client (unfree VMware Horizon client).

**Upjet providers** (`pkgs/upjet-provider-cloudflare/`): upjet-provider-cloudflare. Uses a custom upjet builder.

**Container images** (`pkgs/images/`): github-runner, hercules-ci-agent. Use nix2container; manifests regenerated via `make pkgs/images/<name>/manifest.json`.

**Experimental** (`pkgs/apis/`): protobuf build helper (not yet exposed in overlayAttrs or CI).

### Builders

`builders/` is a flake-parts module that exposes reusable build toolkits:
- **bufTools** (`builders/buf/`) — Protocol Buffer build/generate/convert helpers
- **mangoTools** (`builders/go/`) — Go module init and dep-update helpers
- **kubeVipTools** (`builders/kube-vip/`) — kube-vip manifest builders
- **upjetTools** (`builders/upjet/`) — Upjet provider scaffolding

### Templates

`templates/default/` and `templates/go/` provide starter flakes via `nix flake init -t github:UnstoppableMango/nix#<template>`.

## Adding a new package

1. Create `pkgs/<name>/default.nix` following existing package patterns
2. Add the package to the appropriate submodule in `pkgs/` (e.g., `go.nix` for Go packages, or `pkgs/default.nix` for one-offs)
3. For Go packages: add `gomod2nix.toml` generation targets to the Makefile (add the package name to `GO_PKGS`)
4. Optionally add to `overlayAttrs` in `flake.nix` for external consumption via overlay

## Key conventions

- Format with `nix fmt` before committing
- Follow nixpkgs conventions for package meta (description, homepage, license, maintainers)
- Use `inputs.<input>.follows = "nixpkgs"` to pin transitive inputs
- Avoid IFD (Import From Derivation) for build reproducibility
- CI runs `nix flake check` and builds all packages except aspire-cli
