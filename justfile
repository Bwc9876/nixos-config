GARGS := if env("SPOON_PATH", "") != "" { "--override-input spoon \"$SPOON_PATH\"" } else { "" }

_default:
    @{{ just_executable() }} --list --unsorted --justfile {{ justfile() }}

alias u := update

# u:  update all inputs
update:
    nix flake update

alias b := build

# b:  build the configuration
build:
    nh os build -k . {{ GARGS }}

alias bt := boot

# bt: make the configuration the boot default without activating it
boot:
    nh os boot -k . {{ GARGS }}

alias s := switch

# s:  activate configuration & add to boot menu
switch:
    nh os switch -k --ask . {{ GARGS }}

alias c := check

# c:  run all checks for the current system
check *ARGS:
    nom build --show-trace ".#uberCheck.$(nix eval --impure --raw --expr 'builtins.currentSystem')" --keep-going {{ GARGS }} {{ ARGS }}

alias d := deploy

# d:  deploy the given host
deploy ACTION="switch" HOST="black-mesa":
    NIX_SSHOPTS="-p 8069" nixos-rebuild {{ ACTION }} --flake .#{{ HOST }} --build-host {{ HOST }}.lan --target-host {{ HOST }}.lan --sudo --override-input spoon "git+https://codeberg.org/spoonbaker/mono?ref=devel" --refresh

alias f := format

# f:  format this flake
format:
    nix fmt

alias r := repl

# r:  start a debugging repl
repl:
    nix repl {{ GARGS }} .#repl

alias gc := garbage-collect

# gc: run a garbage collection
garbage-collect:
    nh clean all

alias iso := generate-iso

generate-iso:
    nom build .#nixosConfigurations.installer.config.system.build.isoImage
