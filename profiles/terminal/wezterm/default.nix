{vars, ...}: {
  home-manager.users.${vars.users.primary.name} = {
    pkgs,
    lib,
    config,
    ...
  }: {
    home.packages = with pkgs; [wezterm];

    home.sessionVariables = {
      TERMINAL = lib.getExe pkgs.wezterm;
    };

    xdg.configFile."wezterm".source = config.lib.file.mkOutOfStoreSymlink "/home/${vars.users.primary.name}/systems/profiles/terminal/wezterm";
  };
}
