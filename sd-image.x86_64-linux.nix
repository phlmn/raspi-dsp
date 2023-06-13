{ ... }: {
  nixpkgs.buildPlatform = "x86_64-linux";
  sdImage.compressImage = false;

  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
    ./configuration.nix
  ];
}
