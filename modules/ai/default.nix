{
  inputs,
  vars,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {pkgs, ...}: {
    home.packages = with inputs.nix-ai-tools.packages.${pkgs.system}; [claude-code claudebox];
  };
}
