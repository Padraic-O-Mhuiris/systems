{
  inputs,
  vars,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with inputs.nix-ai-tools.packages.${pkgs.system}; [claudebox claude-desktop claude-code];

    programs.zsh.initContent = ''
      export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.anthropic_api_key.path})"
    '';
  };
}
