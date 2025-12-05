{vars, ...}: {
  home-manager.users.${vars.users.primary.name} = {pkgs, ...}: {
    home.packages = with pkgs; [google-chrome];

    # home.sessionVariables."BROWSER" = pkgs.lib.getExe package;
  };
}
