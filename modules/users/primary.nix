{
  config,
  pkgs,
  vars,
  ...
}: {
  users = {
    mutableUsers = false;
    users."${vars.PRIMARY_USER.NAME}" = {
      uid = vars.PRIMARY_USER.UID;
      isNormalUser = true;
      shell = pkgs.zsh;
      hashedPasswordFile = config.sops.secrets."${vars.PRIMARY_USER.NAME}_password".path;
      extraGroups = [
        "wheel"
        "input"
        "networkmanager"
        "audio"
        "pipewire"
        "video"
      ];
    };
  };

  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    home = {
      homeDirectory = "/home/${vars.PRIMARY_USER.NAME}";
      preferXdgDirectories = true;
    };

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        download = "${config.home.homeDirectory}/downloads";
        extraConfig = {
          XDG_CODE_DIR = "${config.home.homeDirectory}/code";
        };
        desktop = null;
        documents = "documents";
        pictures = null;
        publicShare = null;
        templates = null;
        videos = null;
        music = null;
      };
    };
  };
}