nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=./sd-image.x86_64-linux.nix --no-out-link
