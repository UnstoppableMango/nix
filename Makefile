check:
	nix flake check

update:
	nix flake update

update-provider/%:
	pkgs/terraform-providers/update-provider $*

pkgs/%/update:
	nix-update --flake $*

.vscode/settings.json: hack/vscode.json
	mkdir -p ${@D} && cp $< $@
