{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {pkgs, ...}: {
    home.packages = with pkgs; [google-chrome];

    # home.sessionVariables."BROWSER" = pkgs.lib.getExe package;
  };
}
