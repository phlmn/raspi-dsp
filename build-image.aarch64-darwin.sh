nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=./sd-image.aarch64-darwin.nix --no-out-link
