{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home.sessionVariables = {
      TERMINAL = lib.getExe pkgs.wezterm;
    };

    xdg.configFile."wezterm/wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "/home/padraic/code/nix/padraic.nix/home/terminal/wezterm/wezterm.lua";
  };
}
