NIX       ?= nix
GOMOD2NIX ?= gomod2nix

check:
	$(NIX) flake check --all-systems

build: packages/chart-releaser/gomod2nix.toml
	$(NIX) build .#chart-releaser

# TODO: The generated toml file isn't correct
packages/chart-releaser/gomod2nix.toml:
	$(GOMOD2NIX) generate github.com/helm/chart-releaser --outdir ${@D}

.vscode/settings.json: hack/vscode.json
	mkdir -p ${@D} && cp $< $@
