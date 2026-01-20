# GitHub Copilot Instructions for UnstoppableMango/nix

## Repository Overview

This is a Nix flake repository that aggregates various Nix packages and tools. It's primarily for personal use but available for public consumption.

## Key Technologies

- **Nix Flakes**: Modern Nix package management with `flake.nix` as the entry point
- **flake-parts**: Modular flake configuration system
- **gomod2nix**: Go modules to Nix expressions conversion
- **treefmt-nix**: Code formatting with nixfmt

## Project Structure

- `flake.nix`: Main flake configuration with system-wide settings
- `packages/`: Individual package definitions (aspire-cli, chart-releaser, kubectl-get-all, kubectl-get-resources, mmake, openshift-installer)
- Each package has its own module imported into the main flake

## Development Guidelines

### Nix Code Style

1. **Formatting**: Use `nixfmt` for all Nix files (configured via treefmt)
   - Run `nix fmt` to format the entire project
   - Use 2-space indentation
   
2. **Flake Structure**: Follow the flake-parts modular pattern
   - New packages should be added as separate modules in `packages/`
   - Import new package modules in the main `flake.nix` imports list

3. **Package Definitions**: 
   - Each package should have its own directory under `packages/`
   - Use appropriate fetchers (fetchFromGitHub, fetchurl, etc.)
   - Include proper meta information (description, license, maintainers)

### Common Tasks

- **Add a new package**: Create a new directory under `packages/` with a `default.nix`, then add it to the imports in `flake.nix`
- **Update dependencies**: Run `nix flake update` to update `flake.lock`
- **Test builds**: Use `nix build .#package-name` to test individual packages
- **Development shell**: Use `nix develop` to enter the dev environment with tools like gomod2nix, nil, nixfmt, and nurl

### Best Practices

1. **Follow nixpkgs conventions**: When possible, mirror patterns from nixpkgs
2. **Pin inputs**: Use `inputs.nixpkgs.follows = "nixpkgs"` for consistency
3. **Overlay usage**: Add new packages to `overlayAttrs` for external consumption
4. **System support**: Use the systems flake input to support multiple architectures
5. **Build reproducibility**: Avoid IFD (Import From Derivation) when possible

### Testing

- Build all packages: `nix flake check`
- Build specific package: `nix build .#package-name`
- Test in isolation: Use `nix build` before committing

## Tools and Commands

- `nix develop`: Enter development shell
- `nix fmt`: Format all Nix files
- `nix flake check`: Validate flake and build outputs
- `nix flake update`: Update all flake inputs
- `gomod2nix`: Available as an app via `nix run .#gomod2nix`

## Notes for AI Assistance

- This is a personal aggregator repository, so changes should align with the maintainer's preferences
- When suggesting new packages, provide complete Nix expressions following existing patterns
- Always consider cross-platform compatibility (Linux, macOS, etc.)
- Prefer pure Nix solutions over impure ones
