{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {pkgs, ...}: {
    home.packages = [pkgs.qbittorrent pkgs.vlc];
  };
}
