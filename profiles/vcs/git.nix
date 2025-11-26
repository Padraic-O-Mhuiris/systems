{
  pkgs,
  vars,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
    home.packages = with pkgs; [lazygit];

    home.shellAliases."lg" = "${pkgs.lazygit}/bin/lazygit";

    programs.git = {
      enable = true;
      signing.signByDefault = true;
      signing.key = vars.PRIMARY_USER.GPG_ID;
      ignores = [".direnv"];
      settings.user = {
        email = vars.PRIMARY_USER.EMAIL;
        name = vars.PRIMARY_USER.FULL_NAME;
      };
    };
  };
}
