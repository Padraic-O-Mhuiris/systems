{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs; [wezterm];

    home.sessionVariables = {
      TERMINAL = lib.getExe pkgs.wezterm;
    };

    xdg.configFile."wezterm/wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "/home/${vars.PRIMARY_USER.NAME}/systems/modules/terminal/wezterm/wezterm.lua";
  };
}
