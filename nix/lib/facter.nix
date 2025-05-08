{lib}: let
  inherit (lib) filter last;
in {
  extractWifiInterface = facterReport: let
    inherit (facterReport.hardware) network_controller;
    wifi_device = last (filter (device: device.driver == "iwlwifi") network_controller);
  in
    wifi_device.unix_device_name;
}
