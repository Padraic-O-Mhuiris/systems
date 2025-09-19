{
  config,
  vars,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;
    loadModels = ["gpt-oss:120b"];
    acceleration = "cuda";
  };

  services.nextjs-ollama-llm-ui = {
    enable = true;
    port = 8888;
  };

  environment.persistence."/persist".directories = [config.services.ollama.home];

  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    home.packages = with pkgs; [aider-chat-full claude-code];

    sops.secrets = {
      claude_code = {}; # change to anthropic
      openai = {};
    };

    programs.zsh.initContent = ''
      export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.claude_code.path})"
      export OPEN_API_BASE="https://api.openai.com/v1/models"
      export OPEN_API_KEY="$(cat ${config.sops.secrets.openai.path})"
    '';
  };
}
