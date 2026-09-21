set default-list

alias u := update

# u:  update all inputs
update:
    nix flake update

alias b := build

# b:  build the configuration
build:
    nh os build -k .

alias bu := build-update

# bu: build and update
build-update:
    nh os build -k -u .

alias bt := boot

# bt: make the configuration the boot default without activating it
boot:
    nh os boot -k .

alias s := switch

# s:  activate configuration & add to boot menu
switch:
    nh os switch -k --ask .

alias c := check

# c:  run all checks for the current system
check *ARGS:
    nix flake check --keep-going {{ ARGS }}

alias f := format

# f:  format this flake
format:
    nix fmt

alias r := repl

# r:  start a debugging repl
repl:
    nix repl .#repl

alias gc := garbage-collect

# gc: run a garbage collection
garbage-collect:
    nh clean all

alias iso := generate-iso

generate-iso:
    nom build .#nixosConfigurations.installer.config.system.build.isoImage
