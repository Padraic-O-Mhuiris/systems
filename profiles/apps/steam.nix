{
  # config,
  vars,
  ...
}: {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  home-manager.users.${vars.users.primary.name} = {pkgs, ...}: {
    home.packages = [pkgs.steam];
  };
}
