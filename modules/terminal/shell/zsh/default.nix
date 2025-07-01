{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
      };
    };

    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh";
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      autocd = true;
      historySubstringSearch.enable = true;
      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        ignorePatterns = [];
        ignoreSpace = true;
        path = "${config.xdg.dataHome}/zsh/zsh_history";
        save = 100000;
        share = true;
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "aliases"
          "sudo"
          "direnv"
          "emoji"
          "encode64"
          "jsontools"
          "systemd"
          "dirhistory"
          "command-not-found"
          "colored-man-pages"
          "extract"
        ];
      };
    };

    sops.secrets = {
      atuin_session = {};
      atuin_key = {};
    };

    programs.atuin = {
      enable = true;
      daemon.enable = true;
      enableZshIntegration = true;
      settings = {
        auto_synx = true;
        daemon.enabled = true;
        update_check = false;
        sync_address = "https://api.atuin.sh"; # TODO Change
        sync_frequency = "15m";
        sync.records = true;
        style = "compact";
        dialect = "uk";
        session_path = config.sops.secrets.atuin_session.path;
        key_path = config.sops.secrets.atuin_key.path;
      };
    };
  };
}
