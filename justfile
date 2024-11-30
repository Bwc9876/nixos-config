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
    nom build .#nixosConfigurations.$HOSTNAME.config.system.build.toplevel

[private]
alias s := switch
# s:    activate configuration & add to boot menu
switch: 
    sudo nixos-rebuild switch --flake .# --log-format internal-json |& nom --json

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
    nix-collect-garbage -d
    sudo nix-collect-garbage -d

[private]
alias iso := generate-iso
generate-iso:
    nom build .#nixosConfigurations.installer.config.system.build.isoImage
