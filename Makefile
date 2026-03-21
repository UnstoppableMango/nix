NIX       ?= nix
GOMOD2NIX ?= gomod2nix

PACKAGES := chart-releaser kubectl-get-resources mmake openshift-installer

check:
	$(NIX) flake check --all-systems

build: ${PACKAGES}
${PACKAGES}: %: packages/%/gomod2nix.toml
	$(NIX) build .#$*

update:
	$(NIX) flake update

deps: packages/aspire-cli/deps.json

packages/aspire-cli/deps.json: bin/aspire-cli-deps.sh
	$< $@

bin/aspire-cli-deps.sh:
	$(NIX) build .#aspire-cli.fetch-deps --out-link $@

# TODO: Don't hardcode main ref

packages/chart-releaser/go.mod:
	curl -o $@ https://raw.githubusercontent.com/helm/chart-releaser/refs/heads/main/go.mod
packages/chart-releaser/gomod2nix.toml: packages/chart-releaser/go.mod
	$(GOMOD2NIX) generate --dir ${@D}

packages/kubectl-get-all/go.mod:
	curl -o $@ https://raw.githubusercontent.com/stackitcloud/kubectl-get-all/refs/tags/v1.4.2/go.mod
packages/kubectl-get-all/gomod2nix.toml: packages/kubectl-get-all/go.mod
	$(GOMOD2NIX) generate --dir ${@D}

packages/kubectl-get-resources/go.mod:
	curl -o $@ https://raw.githubusercontent.com/Sandeep-Prajapati/kubectl-get-resources/refs/tags/v0.1.1/go.mod
packages/kubectl-get-resources/gomod2nix.toml: packages/kubectl-get-resources/go.mod
	$(GOMOD2NIX) generate --dir ${@D}

packages/mmake/go.mod:
	curl -o $@ https://raw.githubusercontent.com/tj/mmake/refs/heads/master/go.mod
packages/mmake/gomod2nix.toml: packages/mmake/go.mod
	$(GOMOD2NIX) generate --dir ${@D}

packages/openshift-installer/go.mod:
	curl -o $@ https://raw.githubusercontent.com/openshift/installer/refs/heads/release-4.23/go.mod
packages/openshift-installer/gomod2nix.toml: packages/openshift-installer/go.mod
	$(GOMOD2NIX) generate --dir ${@D}

.vscode/settings.json: hack/vscode.json
	mkdir -p ${@D} && cp $< $@
