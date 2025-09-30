{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {pkgs, ...}: {
    home.packages = with pkgs; [nautilus];

    # TODO This should be under graphical probably
    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus"; # or "Papirus", "Adwaita", etc.
        package = pkgs.papirus-icon-theme;
      };
    };
  };
}
