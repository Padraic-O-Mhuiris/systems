{
  inputs,
  pkgs,
  vars,
  ...
}: let
  inherit (inputs.secrets.packages.${pkgs.system}) berkeley-mono;
in {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      berkeley-mono
      nerdfonts
    ];
  };
}
