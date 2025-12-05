{
  config,
  pkgs,
  vars,
  ...
}: {
  users = {
    mutableUsers = false;
    users."${vars.users.primary.name}" = {
      uid = vars.users.primary.uid;
      isNormalUser = true;
      shell = pkgs.zsh;
      hashedPasswordFile = config.sops.secrets."${vars.users.primary.name}_password".path;
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

  home-manager.users.${vars.users.primary.name} = {config, ...}: {
    home = {
      homeDirectory = "/home/${vars.users.primary.name}";
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