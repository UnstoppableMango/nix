# GitHub Copilot Instructions for UnstoppableMango/nix

## Repository Overview

Personal Nix flake repository that aggregates various Nix packages and tools. Available for public consumption via overlay.

## Key Technologies

- **Nix Flakes**: Modern Nix package management with `flake.nix` as the entry point
- **flake-parts**: Modular flake configuration system
- **gomod2nix**: Go modules to Nix expressions conversion
- **nix2container**: Container image builds
- **treefmt-nix**: Code formatting with nixfmt

## Project Structure

```
flake.nix          # Main flake — imports ./lib and ./pkgs
lib/               # Library extensions
  default.nix      # Extends pkgs.lib with lib.go and lib.maintainers; exports mangoTools
  go/              # Go helpers: mkUpdateDeps, modInit
  maintainers.nix  # Custom maintainer entries
pkgs/              # All package definitions
  default.nix      # Defines most packages; imports ./kube-vip, ./images
  aspire-cli/      # .NET CLI tool (buildDotnetModule)
  images/          # Container images (github-runner, hercules-ci-agent)
  kube-vip/        # kube-vip Go package
  terraform-providers/  # mkProvider builder + named providers
  <name>/          # Individual Go/Python/other packages
templates/         # Starter flakes (default, go)
```

## Packages

**Go** (use `buildGoApplication` from gomod2nix, require `gomod2nix.toml`):
chart-releaser, kube-vip, kubectl-get-all, kubectl-get-resources, kubectl-slice, mmake, openshift-installer, smarter-device-manager, terraform-plugin-codegen-openapi, terraform-provider-pfsense

**Dotnet**: aspire-cli (`buildDotnetModule`, deps in `pkgs/aspire-cli/deps.json`)

**Python**: awxkit

**Other**: omnissa-horizon-client (unfree)

**Terraform provider collection** (`pkgs/terraform-providers/`): exposes `mkProvider` builder and named providers; in `legacyPackages` only

**Container images** (`pkgs/images/`): github-runner, hercules-ci-agent (nix2container)

**Overlay** (available to external flakes): awxkit, chart-releaser, kubectl-get-all, kubectl-get-resources, kubectl-slice, mmake, openshift-installer

## Development Guidelines

### Nix Code Style

1. **Formatting**: Run `nix fmt` before committing (nixfmt via treefmt)
2. **Flake structure**: Follow flake-parts modular pattern — new packages go in `pkgs/default.nix`, not directly in `flake.nix`
3. **Package definitions**: Each package in its own directory under `pkgs/`; include meta (description, license, maintainers)
4. **Avoid IFD** (Import From Derivation) for build reproducibility
5. **Pin inputs**: Use `inputs.<input>.follows = "nixpkgs"` for transitive inputs

### Common Tasks

- **Add a package**: Create `pkgs/<name>/default.nix`, add to `pkgs/default.nix`, add name to `GO_PKGS` in Makefile for Go packages
- **Update flake inputs**: `make update` (`nix flake update`)
- **Regenerate Go deps**: `make pkgs/<name>/gomod2nix.toml`
- **Regenerate all deps**: `make deps`
- **Update a terraform provider**: `make update-provider/<name>`
- **Build specific package**: `nix build .#<name>`
- **Build all Go packages**: `make build`
- **Validate**: `nix flake check`
- **Dev shell**: `nix develop` (provides: gomod2nix, nil, nixfmt, nix-update, nurl, watchexec)

### Lib module

`lib/` extends `pkgs.lib` and exposes via `legacyPackages`:
- `mangoTools.mkUpdateDeps src` — generates `gomod2nix.toml` from upstream source
- `mangoTools.modInit src modulePath` — initializes a Go module and produces a patch

## Notes for AI Assistance

- New packages belong in `pkgs/default.nix`, not as new flake-parts imports in `flake.nix`
- Go packages need `gomod2nix.toml`; regenerate with `make pkgs/<name>/gomod2nix.toml`
- Follow nixpkgs meta conventions (description, homepage, license, maintainers)
- Prefer pure Nix; avoid IFD
- Consider cross-platform support (Linux, macOS, multiple architectures)
