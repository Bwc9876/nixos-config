GARGS := if env("SPOON_PATH", "") != "" {"--override-input spoon \"$SPOON_PATH\""} else { "" }

_default:
    @{{ just_executable() }} --list --unsorted --justfile {{ justfile() }}

[private]
alias u := update
# u:  update all inputs
update:
    nix flake update

[private]
alias b := build
# b:  build the configuration
build:
    nh os build . {{ GARGS }}

[private]
alias bt := boot
# bt: make the configuration the boot default without activating it
boot:
    nh os boot . {{ GARGS }}

[private]
alias s := switch
# s:  activate configuration & add to boot menu
switch: 
    nh os switch --ask . {{ GARGS }}

[private]
alias c := check
# c:  run all checks for the current system
check *ARGS:
    nix flake check --show-trace {{ GARGS }} {{ ARGS }} --log-format internal-json -v |& nom --json

[private]
alias d := deploy
# d:  deploy the given host
deploy ACTION="switch" HOST="black-mesa":
    NIX_SSHOPTS="-p 8069" nixos-rebuild {{ ACTION }} --flake .#{{ HOST }} --build-host {{ HOST }}.lan --target-host {{ HOST }}.lan --sudo --override-input spoon "git+https://codeberg.org/spoonbaker/mono?ref=devel" --refresh

[private]
alias f := format
# f:  format this flake
format:
    nix fmt

[private]
alias r := repl
# r:  start a debugging repl
repl:
    nix repl {{ GARGS }} .#repl

[private]
alias gc := garbage-collect
# gc: run a garbage collection
garbage-collect:
    nh clean all

[private]
alias iso := generate-iso
generate-iso:
    nom build .#nixosConfigurations.installer.config.system.build.isoImage


