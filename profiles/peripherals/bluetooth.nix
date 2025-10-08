{
  pkgs,
  vars,
  ...
}:
# https://discourse.nixos.org/t/bluetooth-troubles/38940/11
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez5-experimental;
    settings = {
      General = {
        # Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        KernelExperimental = true;
      };
      Policy.AutoEnable = "true";
    };
  };
  services.blueman.enable = true;

  boot.kernelModules = ["btusb" "btintel"];
  boot.kernelParams = [
    "btusb.enable_autosuspend=0"
    "bluetooth.disable_ertm=1"
  ];

  environment.systemPackages = with pkgs; [
    bluez5-experimental
    bluez-tools
    bluez-alsa
    bluetuith
  ];

  home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
    services.blueman-applet.enable = true;
  };
}
