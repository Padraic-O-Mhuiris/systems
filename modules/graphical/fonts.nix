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
      iosevka
      corefonts
      dejavu_fonts
      liberation_ttf
      roboto
      fira-code
      jetbrains-mono
      siji
      font-awesome
      nerdfonts
    ];
  };
}
