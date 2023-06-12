nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=./sd-image.cross.nix --argstr system aarch64-linux --no-out-link
