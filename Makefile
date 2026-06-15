CS_PKGS  := aspire-cli
GO_PKGS  := chart-releaser kube-vip kubectl-get-all kubectl-get-resources kubectl-slice mmake openshift-installer terraform-plugin-codegen-framework terraform-plugin-codegen-openapi terraform-provider-pfsense
IMAGES   := github-runner
ALL_PKGS := ${CS_PKGS} ${GO_PKGS} ${IMAGES} omnissa-horizon-client

check:
	nix flake check

build: ${GO_PKGS}
${GO_PKGS}: %: pkgs/%/gomod2nix.toml
	nix build .#$*

update:
	nix flake update

update-provider/%:
	pkgs/terraform-providers/update-provider $*

deps: ${CS_PKGS:%=pkgs/%/deps.json} ${GO_PKGS:%=pkgs/%/gomod2nix.toml} ${IMAGES:%=pkgs/images/%/manifest.json}

pkgs/%/deps.json: pkgs/%/default.nix
	"$$(nix build .#$*.fetch-deps --print-out-paths)" ${CURDIR}/$@

pkgs/%/gomod2nix.toml: pkgs/%/default.nix
	"$$(nix build .#$*.update-deps --print-out-paths)/bin/update-deps" ${CURDIR}/$@

pkgs/%/update: pkgs/%/default.nix
	nix-update --flake $*

pkgs/%/gomod.patch: pkgs/%/default.nix
	"$$(nix build .#$*.go-mod-patch --print-out-paths)/bin/go-mod-init" >${CURDIR}/$@

pkgs/images/%/manifest.json: pkgs/images/%/default.nix
	nix run .#images.$*.fromImage.getManifest > $@

.vscode/settings.json: hack/vscode.json
	mkdir -p ${@D} && cp $< $@
