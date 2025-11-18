{vars, ...}: {
  programs.zsh.enable = true;

  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    programs = {
      command-not-found.enable = true;

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          add_newline = false;
        };
      };

      zsh = {
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
    };
  };
}
