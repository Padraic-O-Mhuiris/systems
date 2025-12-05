{vars, ...}: {
  home-manager.users.${vars.users.primary.name} = {pkgs, ...}: {
    home.packages = [pkgs.obsidian];
  };
}
