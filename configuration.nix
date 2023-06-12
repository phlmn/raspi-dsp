{ config, pkgs, lib, ... }:
let
  wifi_config = if builtins.pathExists /etc/nixos/wifi_config.nix then (import /etc/nixos/wifi_config.nix) else {};
  camilladsp = (pkgs.callPackage ./camilladsp.nix {});
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking = {
    useNetworkd = true;
    hostName = "dsp";
    useDHCP = true;
  };

  systemd.network.networks."enu1u1" = {
    linkConfig.RequiredForOnline = "no";
  };

  services.hostapd = {
    enable = true;
    interface = "wlan0";
    ssid = wifi_config.ssid or "raspi DSP";
    wpaPassphrase = wifi_config.passphrase or "s0undsystem";
    countryCode = "DE";
  };

  networking.networkmanager.unmanaged = [ "interface-name:${config.services.hostapd.interface}" ];
  networking.interfaces."wlan0".ipv4.addresses = [{ address = "192.168.12.1"; prefixLength = 24; }];

  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "wlan0";
      bind-interfaces = true;
      dhcp-range = [ "192.168.12.10,192.168.12.254,24h" ];
    };
  };

  services.haveged.enable = config.services.hostapd.enable;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGEEnbbN+qgKF36yjzq2TPBzyZUGtDJH4SYV4gmbDMT phlmn@Meins"
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    alsa-lib
    alsa-utils
    (pkgs.callPackage ./camilladsp.nix {})
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
    ipv4 = true;
    ipv6 = false;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  networking.firewall.enable = false;

  # do not write journal to disk to save sd card
  systemd.services.systemd-journal-flush.enable = false;

  systemd.services.sd-card-config = {
    description = "apply config from sd card";
    script = ''
      if test -f "/boot/firmware/wifi_config.nix"; then
        export NIX_PATH="/root/.nix-defexpr/channels:nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels"

        echo "config changed, rebuilding"

        mv /boot/firmware/wifi_config.nix /etc/nixos/wifi_config.nix
        /run/current-system/sw/bin/nixos-rebuild switch || echo "rebuild failed"
      fi
    '';
    wantedBy = [ "multi-user.target" ];
  };

  # systemd.services.camilladsp = {
  #   description = "camilladsp";
  #   script = ''
  #     ${camilladsp.out}/camilladsp -c ${camilladsp.config}
  #   '';
  #   unitConfig = {
  #     StartLimitIntervalSec = "0";
  #   };
  #   serviceConfig = {
  #     Restart = "always";
  #     RestartSec = "1s";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
