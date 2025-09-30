{
  vars,
  systemPkgs,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    pkgs,
    lib,
    ...
  }: let
    claudeDirPath = "/home/${vars.PRIMARY_USER.NAME}/systems/profiles/ai/claude";
    inherit (systemPkgs.${pkgs.system}) claude-code cc;
  in {
    home.file.".claude" = {
      source = lib.mkForce (
        config.lib.file.mkOutOfStoreSymlink claudeDirPath
      );
      recursive = true;
    };

    home.packages = [
      claude-code
      cc
    ];
  };
}
