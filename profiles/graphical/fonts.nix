{
  inputs,
  pkgs,
  vars,
  ...
}: let
  inherit (inputs.secrets.packages.${pkgs.stdenv.hostPlatform.system}) berkeley-mono;
in {
  home-manager.users.${vars.users.primary.name} = _: {
    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = ["Berkeley Mono"];
    };

    home.packages = [
      berkeley-mono
      pkgs.iosevka
    ];
  };
}
