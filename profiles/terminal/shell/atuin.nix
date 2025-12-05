{vars, ...}: {
  home-manager.users.${vars.users.primary.name} = {config, ...}: {
    programs.atuin = {
      enable = true;
      daemon.enable = true;
      enableZshIntegration = true;
      settings = {
        auto_synx = true;
        daemon.enabled = true;
        update_check = false;
        sync_address = "https://api.atuin.sh"; # TODO Change
        sync_frequency = "15m";
        sync.records = true;
        style = "compact";
        dialect = "uk";
        session_path = config.sops.secrets.atuin_session.path;
        key_path = config.sops.secrets.atuin_key.path;
      };
    };
  };
}
