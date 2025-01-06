_default:
    @just --list --unsorted --justfile {{justfile()}}

[private]
alias u := update
# u:    update all inputs
update:
    nix flake update

[private]
alias b := build
# b:    build the configuration
build:
    nh os build .

[private]
alias s := switch
# s:    activate configuration & add to boot menu
switch: 
    nh os switch --ask .

[private]
alias c := check
# c:    run flake checks, including making sure `.#repl` and the system config evaluate
check:
    nix flake check .# --show-trace

[private]
alias f := format
# f: run nix fmt on the flake
format:
    nix fmt

[private]
alias gc := garbage-collect
# gc: Run nix collect-garbage -d
garbage-collect:
    nh clean all

[private]
alias iso := generate-iso
generate-iso:
    nom build .#nixosConfigurations.installer.config.system.build.isoImage
