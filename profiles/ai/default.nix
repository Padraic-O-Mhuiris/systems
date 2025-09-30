{
  vars,
  system,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    imports = [system.homeManagerModules.cc];

    programs.cc = let
      claudeMdPath = "/home/${vars.PRIMARY_USER.NAME}/systems/profiles/ai/claude/.claude.md";
    in {
      enable = true;
      apiKeyPath = config.sops.secrets.anthropic_api_key.path;
      settings = {
        model = "claude-sonnet-4-5-20250929";
      };

      memory.source = config.lib.file.mkOutOfStoreSymlink claudeMdPath;
      agentsDir = ./claude/agents;
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
