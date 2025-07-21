{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    pkgs,
    # lib,
    ...
  }: {
    home.packages = with pkgs; [ghostty];

    # home.sessionVariables = {
    #   TERMINAL = lib.getExe pkgs.ghostty;
    # };

    xdg.configFile."ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "/home/${vars.PRIMARY_USER.NAME}/systems/modules/terminal/ghostty/config";
  };
}
