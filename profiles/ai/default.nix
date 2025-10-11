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
        model = "claude-sonnet-4-5-20250929";
      };

      memory.source = config.lib.file.mkOutOfStoreSymlink "${claudeConfigs}/.claude.md";
      agentsDir = config.lib.file.mkOutOfStoreSymlink "${claudeConfigs}/agents";
    };
  };
}
