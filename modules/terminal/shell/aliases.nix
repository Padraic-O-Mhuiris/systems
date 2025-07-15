{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {osConfig}: {
    home = {
      shellAliases = {
        # TODO Create default filesystem location for this nixos repository
        "nr" = "sudo nixos-rebuild --flake $HOME/systems#${osConfig.networking.hostName} switch --show-trace --verbose";
      };
    };
  };
}
