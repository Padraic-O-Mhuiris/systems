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
    claudeDirPath = "/home/${vars.PRIMARY_USER.NAME}/systems/modules/ai/claude";

    claudeCodeSettings = pkgs.writeTextFile {
      name = "claude-code-cc-settings.json";
      text =
        #json
        ''
          {
            "apiKeyHelper": "cat ${config.sops.secrets.anthropic_api_key.path}",
            "hasCompletedOnboarding": true
          }
        '';
    };

    cc = pkgs.symlinkJoin {
      name = "claude-code-cc";
      paths = [inputs.nix-ai-tools.packages.${pkgs.system}.claude-code];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        makeWrapper $out/bin/claude $out/bin/cc \
          --add-flags "--settings ${claudeCodeSettings}"
      '';
    };
  in {
    home.file.".claude" = {
      source = lib.mkForce (
        config.lib.file.mkOutOfStoreSymlink claudeDirPath
      );
      recursive = true;
    };

    home.packages = with inputs.nix-ai-tools.packages.${pkgs.system}; [
      claudebox
      claude-desktop
      cc
    ];

    # programs.zsh.initContent = ''
    #   export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.anthropic_api_key.path})"
    # '';
  };
}
