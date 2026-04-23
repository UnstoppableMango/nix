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

deps: ${CS_PKGS:%=packages/%/deps.json} ${GO_PKGS:%=packages/%/gomod2nix.toml}

packages/%/deps.json: packages/%/default.nix
	"$$(nix build .#$*.fetch-deps --print-out-paths)" ${CURDIR}/$@

packages/%/gomod2nix.toml: packages/%/default.nix
	nix run .#update-$*-deps >$@

packages/smarter-device-manager/go.mod:
	printf '%s\n' \
		'module arm.com/smarter-device-management' \
		'' \
		'go 1.20' \
		'' \
		'require (' \
		'	github.com/fsnotify/fsnotify v1.4.9' \
		'	github.com/golang/glog v0.0.0-20160126235308-23def4e6c14b' \
		'	golang.org/x/net v0.0.0-20201110031124-69a78807bb2b' \
		'	google.golang.org/grpc v1.27.1' \
		'	gopkg.in/yaml.v2 v2.2.8' \
		'	k8s.io/kubelet v0.20.12' \
		')' \
		'' \
		'require (' \
		'	github.com/gogo/protobuf v1.3.2 // indirect' \
		'	github.com/golang/protobuf v1.4.3 // indirect' \
		'	golang.org/x/sys v0.0.0-20201112073958-5cba982894dd // indirect' \
		'	golang.org/x/text v0.3.6 // indirect' \
		'	google.golang.org/genproto v0.0.0-20201110150050-8816d57aaa9a // indirect' \
		'	google.golang.org/protobuf v1.25.0 // indirect' \
		')' > $@
packages/smarter-device-manager/gomod2nix.toml: packages/smarter-device-manager/go.mod
	$(GOMOD2NIX) generate --dir ${@D}

.vscode/settings.json: hack/vscode.json
	mkdir -p ${@D} && cp $< $@
