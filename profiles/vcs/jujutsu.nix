{
  pkgs,
  vars,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
    home.packages = with pkgs; [jujutsu];
  };
}
