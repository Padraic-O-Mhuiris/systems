{
  vars,
  system,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    pkgs,
    ...
  }: {
    imports = [system.homeManagerModules.cc];

    programs.cc = let
      claudeConfigs = "/home/${vars.PRIMARY_USER.NAME}/systems/profiles/ai/claude";
    in {
      enable = true;
      package = system.packages.${pkgs.system}.claude-code;
      apiKeyPath = config.sops.secrets.anthropic_api_key.path;
      settings = {
        model = "claude-haiku-4-5-20251001";
        "permissions"."deny" = [
          "*(./.git/**)"
        ];
      };

      memory.source = config.lib.file.mkOutOfStoreSymlink "${claudeConfigs}/.claude.md";
      agentsDir = config.lib.file.mkOutOfStoreSymlink "${claudeConfigs}/agents";
    };
  };
}
