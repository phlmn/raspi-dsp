{ ... }: {
  nixpkgs.buildPlatform = "aarch64-darwin";
  sdImage.compressImage = false;

  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
    ./configuration.nix
  ];
}
