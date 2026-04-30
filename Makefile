CS_PKGS  := aspire-cli
GO_PKGS  := chart-releaser kubectl-get-resources mmake openshift-installer smarter-device-manager
ALL_PKGS := ${CS_PKGS} ${GO_PKGS} omnissa-horizon-client

check:
	nix flake check

build: ${GO_PKGS}
${GO_PKGS}: %: packages/%/gomod2nix.toml
	nix build .#$*

update:
	nix flake update

deps: ${CS_PKGS:%=packages/%/deps.json} ${GO_PKGS:%=packages/%/gomod2nix.toml}

packages/%/deps.json: packages/%/default.nix
	"$$(nix build .#$*.fetch-deps --print-out-paths)" ${CURDIR}/$@

packages/%/gomod2nix.toml: packages/%/default.nix packages/update-deps.nix
	"$$(nix build .#$*.update-deps --print-out-paths)/bin/update-deps" ${CURDIR}/$@

.vscode/settings.json: hack/vscode.json
	mkdir -p ${@D} && cp $< $@
