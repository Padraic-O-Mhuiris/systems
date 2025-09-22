{
  inputs,
  pkgs,
  vars,
  ...
}: let
  inherit (inputs.secrets.packages.${pkgs.system}) berkeley-mono;
in {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {...}: {
    fonts.fontconfig.enable = true;

    home.packages = [
      berkeley-mono
    ];
  };
}
