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
        # Languages & runtimes
        python3
        nodejs

        # Infrastructure
        kubectl

        # PDF tools
        pdftk
        qpdf

        # Modern CLI tools (mentioned in .claude.md preferences)
        bat
        eza
        yq-go
        fzf
        delta
        gh
      ];

      memory.source = config.lib.file.mkOutOfStoreSymlink "${claudeConfigs}/.claude.md";
      agentsDir = config.lib.file.mkOutOfStoreSymlink "${claudeConfigs}/agents";
    };
  };
}
