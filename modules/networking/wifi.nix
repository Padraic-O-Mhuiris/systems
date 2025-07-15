{config, ...}: {
  sops.secrets."wifi_home_ssid" = {};
  sops.secrets."wifi_home_psk" = {};

  networking = {
    # Disable wpa_supplicant
    wireless.enable = false;

    networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [
          config.sops.secrets."wifi_home_ssid".path
          config.sops.secrets."wifi_home_psk".path
        ];
        profiles = {
          "home" = {
            connection = {
              id = "home";
              type = "wifi";
              autoconnect = true;
            };
            ipv4 = {
              method = "manual";
              dns = "192.168.0.1";
              gateway = "192.168.0.1";
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$HOME_SSID";
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk = "$HOME_PSK";
            };
          };
        };
      };
    };
  };
}
