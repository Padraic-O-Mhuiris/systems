{
  inputs,
  vars,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    pkgs,
    lib,
    ...
  }: let
    claudeSrcPath = "/home/${vars.PRIMARY_USER.NAME}/systems/modules/ai/claude";
  in {
    home.file.".claude" = {
      source = lib.mkForce (
        config.lib.file.mkOutOfStoreSymlink claudeSrcPath
      );
      recursive = true;
    };

    home.file.".claude/settings.json".text =
      #json
      ''
        {
          "apiKeyHelper": "cat ${config.sops.secrets.anthropic_api_key.path}"
        }
      '';

    # {
    #   source = lib.mkForce (
    #     config.lib.file.mkOutOfStoreSymlink claudeSrcPath
    #   );
    #   recursive = true;
    # };

    home.packages = with inputs.nix-ai-tools.packages.${pkgs.system}; [claudebox claude-desktop claude-code];

    programs.zsh.initContent = ''
      export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.anthropic_api_key.path})"
    '';
  };
}
