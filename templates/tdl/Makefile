MODEL := $(wildcard model/*.tdl)

build gen:
	tdl gen $(MODEL)

update:
	nix flake update

check lint:
	nix flake check

format fmt:
	nix fmt
