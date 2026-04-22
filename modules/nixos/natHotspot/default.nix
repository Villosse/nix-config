{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.natHotspot;
in
{
  options.natHotspot = {
    enable = mkEnableOption "NAT hotspot (share wifi over ethernet/switch)";

    internalInterface = mkOption {
      type = types.str;
      example = "enp3s0";
      description = "Ethernet interface connected to the switch (run: ip link)";
    };

    externalInterface = mkOption {
      type = types.str;
      example = "wlp2s0";
      description = "Wifi interface with internet access (run: ip link)";
    };

    gatewayAddress = mkOption {
      type = types.str;
      default = "192.168.2.1";
      description = "Static IP assigned to the internal interface (gateway for LAN clients)";
    };

    prefixLength = mkOption {
      type = types.int;
      default = 24;
      description = "Subnet prefix length";
    };

    dhcpRangeStart = mkOption {
      type = types.str;
      default = "192.168.2.100";
      description = "Start of DHCP address range";
    };

    dhcpRangeEnd = mkOption {
      type = types.str;
      default = "192.168.2.200";
      description = "End of DHCP address range";
    };

    dhcpLeaseTime = mkOption {
      type = types.str;
      default = "24h";
      description = "DHCP lease duration";
    };
  };

  config = mkIf cfg.enable {
    # Tell NetworkManager to leave the internal interface alone
    networking.networkmanager.unmanaged = [ cfg.internalInterface ];

    networking.nat = {
      enable = true;
      internalInterfaces = [ cfg.internalInterface ];
      externalInterface = cfg.externalInterface;
    };

    # Use systemd-networkd to reliably assign the static IP
    # (networking.interfaces doesn't work well alongside NetworkManager)
    systemd.network.enable = true;
    systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
    systemd.network.networks."10-${cfg.internalInterface}" = {
      matchConfig.Name = cfg.internalInterface;
      address = [ "${cfg.gatewayAddress}/${toString cfg.prefixLength}" ];
      linkConfig.RequiredForOnline = "no";
      networkConfig.ConfigureWithoutCarrier = true;
    };

    services.dnsmasq = {
      enable = true;
      settings = {
        port = 0;
        interface = cfg.internalInterface;
        dhcp-range = [ "${cfg.dhcpRangeStart},${cfg.dhcpRangeEnd},${cfg.dhcpLeaseTime}" ];
        dhcp-option = [ "option:dns-server,8.8.8.8,8.8.4.4" ];
      };
    };

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    # Allow DHCP requests from internal interface
    networking.firewall.interfaces."${cfg.internalInterface}".allowedUDPPorts = [
      67
      68
    ];
  };
}
