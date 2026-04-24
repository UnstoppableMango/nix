CS_PKGS  := aspire-cli
GO_PKGS  := chart-releaser kubectl-get-resources mmake openshift-installer
ALL_PKGS := ${CS_PKGS} ${GO_PKGS} omnissa-horizon-client

check:
	nix flake check

build: ${GO_PKGS}
${GO_PKGS}: %: packages/%/gomod2nix.toml
	nix build .#$*

update:
	nix flake update

deps: ${CS_PKGS:%=packages/%/deps.json} ${GO_PKGS:%=packages/%/gomod2nix.toml} packages/smarter-device-manager/gomod2nix.toml

packages/%/deps.json: packages/%/default.nix
	"$$(nix build .#$*.fetch-deps --print-out-paths)" ${CURDIR}/$@

packages/%/gomod2nix.toml: packages/%/default.nix
	nix run .#update-$*-deps >$@

packages/smarter-device-manager/go.mod packages/smarter-device-manager/go.sum packages/smarter-device-manager/gomod2nix.toml &: packages/smarter-device-manager/default.nix
	nix run .#update-smarter-device-manager-deps

.vscode/settings.json: hack/vscode.json
	mkdir -p ${@D} && cp $< $@
