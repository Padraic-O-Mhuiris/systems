{vars, ...}: let
  ireland = {
    latitude = 53.33;
    longitude = -6.24;
  };
in {
  home-manager.users.${vars.users.primary.name} = _: {
    services.gammastep = {
      inherit (ireland) latitude longitude;
      enable = true;
      tray = true;
      temperature = {
        night = 2500;
      };
      provider = "manual";
    };
  };
}
