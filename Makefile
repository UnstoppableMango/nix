NIX       ?= nix
GOMOD2NIX ?= gomod2nix

check:
	$(NIX) flake check --all-systems

build: pkgs/chart-releaser/gomo2nix.toml
	$(NIX) build

# TODO: The generated toml file isn't correct
pkgs/chart-releaser/gomo2nix.toml:
	$(GOMOD2NIX) generate github.com/helm/chart-releaser --outdir ${@D}

.vscode/settings.json: hack/vscode.json
	mkdir -p ${@D} && cp $< $@
