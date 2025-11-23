NIX ?= nix

check:
	$(NIX) flake check --all-systems

build:
	$(NIX) build

.vscode/settings.json: hack/vscode.json
	mkdir -p ${@D} && cp $< $@
