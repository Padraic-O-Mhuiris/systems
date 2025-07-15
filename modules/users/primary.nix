{
  config,
  pkgs,
  vars,
  ...
}: {
  sops.secrets."${vars.PRIMARY_USER.NAME}_password" = {
    neededForUsers = true;
  };

  users = {
    mutableUsers = false;
    users."${vars.PRIMARY_USER.NAME}" = {
      isNormalUser = true;
      createHome = true;
      shell = pkgs.zsh;

      hashedPasswordFile = config.sops.secrets."${vars.PRIMARY_USER.NAME}_password".path;
      group = "users";

      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "pipewire"
        "video"
      ];
    };
  };

  home-manager.users.${vars.PRIMARY_USER.NAME} = _: {
    home.homeDirectory = "/home/${vars.PRIMARY_USER.NAME}";
  };
}
