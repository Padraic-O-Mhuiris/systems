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
    imports = [system.homeManagerModules.claude-box];

    programs.claude-box = let
      claudeConfigs = "/home/${vars.PRIMARY_USER.NAME}/systems/profiles/ai/claude";
    in {
      enable = true;
      package = system.packages.${pkgs.system}.claude-code;
      apiKeyPath = config.sops.secrets.anthropic_api_key.path;
      settings = {
        model = "claude-sonnet-4-5-20250929";
        "permissions"."deny" = [
          "*(./.git/**)"
        ];
      };
      extraPackages = with pkgs; [
        python3
        nodejs
        kubectl
      ];

      memory.source = config.lib.file.mkOutOfStoreSymlink "${claudeConfigs}/.claude.md";
      agentsDir = config.lib.file.mkOutOfStoreSymlink "${claudeConfigs}/agents";
    };
  };
}
