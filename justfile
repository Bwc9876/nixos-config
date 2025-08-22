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
    nh os build .

[private]
alias bt := boot
# bt: make the configuration the boot default without activating it
boot:
    nh os boot .

[private]
alias s := switch
# s:  activate configuration & add to boot menu
switch: 
    nh os switch --ask .

[private]
alias c := check
# c:  run all checks for the current system
check *ARGS:
    nix flake check --show-trace {{ if env("SPOON_PATH", "") != "" {"--override-input spoon \"$SPOON_PATH\" --no-build"} else { "" } }} {{ ARGS }} --log-format internal-json -v |& nom --json

[private]
alias f := format
# f:  format this flake
format:
    nix fmt

[private]
alias r := repl
# r:  start a debugging repl
repl:
    nix repl .#repl

[private]
alias gc := garbage-collect
# gc: run a garbage collection
garbage-collect:
    nh clean all

[private]
alias iso := generate-iso
generate-iso:
    nom build .#nixosConfigurations.installer.config.system.build.isoImage
