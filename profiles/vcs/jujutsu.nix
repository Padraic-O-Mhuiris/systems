{
  pkgs,
  vars,
  ...
}: {
  home-manager.users.${vars.users.primary.name} = _: {
    home.packages = with pkgs; [jujutsu];
  };
}
