{
  vars,
  system,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
    imports = [system.homeManagerModules.cc];

    programs.cc = {
      enable = true;
    };

    # home.file.".claude" = {
    #   source = lib.mkForce (
    #     config.lib.file.mkOutOfStoreSymlink claudeDirPath
    #   );
    #   recursive = true;
    # };

    # home.packages = [
    #   claude-code
    #   cc
    # ];
  };
}
