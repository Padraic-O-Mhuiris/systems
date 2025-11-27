{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    pkgs,
    lib,
    config,
    ...
  }: {
    home.packages = with pkgs; [wezterm];

    home.sessionVariables = {
      TERMINAL = lib.getExe pkgs.wezterm;
    };

    xdg.configFile."wezterm".source = config.lib.file.mkOutOfStoreSymlink "/home/${vars.PRIMARY_USER.NAME}/systems/profiles/terminal/wezterm";
  };
}
