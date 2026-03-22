# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

Personal Nix flake repository that aggregates various Nix packages and tools. Uses **flake-parts** for modular flake configuration and **gomod2nix** for Go-based packages.

## Commands

```bash
nix develop          # Enter dev shell (provides: gomod2nix, nil, nixfmt, nurl)
nix fmt              # Format all Nix files with nixfmt
nix flake check      # Validate flake and build all outputs
nix flake check --all-systems  # Check across all supported systems (also: make check)
nix build .#<name>   # Build a specific package
make build           # Build all Go packages
make update          # Update flake.lock (nix flake update)
make deps            # Generate aspire-cli deps.json
```

To regenerate `gomod2nix.toml` for a Go package (e.g., after version bump):
```bash
make packages/<name>/gomod2nix.toml
```
This fetches the upstream `go.mod` and runs `gomod2nix generate`.

## Architecture

### Flake structure

`flake.nix` uses flake-parts modules. Each package in `packages/` is a standalone flake-parts module imported into `flake.nix`. New packages must be added to both `packages/` and the `imports` list in `flake.nix`.

Packages are also exposed via `overlayAttrs` so other flakes can consume them as an overlay.

### Go packages

All Go packages (chart-releaser, kubectl-get-all, kubectl-get-resources, mmake, openshift-installer) use `buildGoApplication` from gomod2nix. Each requires a `gomod2nix.toml` generated from the upstream `go.mod`. The Makefile fetches upstream `go.mod` files via `curl` and then runs `gomod2nix generate`.

### Non-Go packages

- **aspire-cli**: Uses `buildDotnetModule`; deps generated via `bin/aspire-cli-deps.sh` (built from the package's `fetch-deps` output)

### Templates

`templates/default/` and `templates/go/` provide starter flakes via `nix flake init -t github:UnstoppableMango/nix#<template>`.

## Adding a new package

1. Create `packages/<name>/default.nix` following existing package patterns
2. Add the module to the `imports` list in `flake.nix`
3. Add it to `overlayAttrs` in `flake.nix` for external consumption
4. For Go packages: add `go.mod` fetch and `gomod2nix.toml` generation targets to the Makefile

## Key conventions

- Format with `nix fmt` before committing
- Follow nixpkgs conventions for package meta (description, homepage, license, maintainers)
- Use `inputs.<input>.follows = "nixpkgs"` to pin transitive inputs
- Avoid IFD (Import From Derivation) for build reproducibility
- CI runs `nix flake check` and builds all packages except aspire-cli
