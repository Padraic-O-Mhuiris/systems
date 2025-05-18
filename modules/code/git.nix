{
  pkgs,
  vars,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    home.packages = with pkgs; [lazygit];

    home.shellAliases."lg" = "${pkgs.lazygit}/bin/lazygit";

    programs.git = {
      enable = true;
      signing.signByDefault = true;
      userEmail = vars.PRIMARY_USER.EMAIL;
      userName = vars.PRIMARY_USER.FULL_NAME;
      signing.key = vars.PRIMARY_USER.GPG_ID;
    };
  };
}
