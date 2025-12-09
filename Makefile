NIX       ?= nix
GOMOD2NIX ?= gomod2nix

PACKAGES := chart-releaser mmake

check:
	$(NIX) flake check --all-systems

build: ${PACKAGES}

deps: packages/aspire-cli/deps.json

packages/aspire-cli/deps.json: bin/aspire-cli-deps.sh
	$< $@

bin/aspire-cli-deps.sh:
	$(NIX) build .#aspire-cli.fetch-deps --out-link $@

${PACKAGES}: %: packages/%/gomod2nix.toml
	$(NIX) build .#$*

packages/chart-releaser/go.mod:
	curl -o $@ https://raw.githubusercontent.com/helm/chart-releaser/refs/heads/main/go.mod
packages/chart-releaser/gomod2nix.toml: packages/chart-releaser/go.mod
	$(GOMOD2NIX) generate --dir ${@D}

packages/mmake/go.mod:
	curl -o $@ https://raw.githubusercontent.com/tj/mmake/refs/heads/master/go.mod
packages/mmake/gomod2nix.toml: packages/mmake/go.mod
	$(GOMOD2NIX) generate --dir ${@D}

.vscode/settings.json: hack/vscode.json
	mkdir -p ${@D} && cp $< $@
