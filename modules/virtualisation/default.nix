{vars, ...}: {
  virtualisation.docker = {
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
      # Optionally customize rootless Docker daemon settings
      daemon.settings = {
        dns = ["1.1.1.1" "8.8.8.8"];
        registry-mirrors = ["https://mirror.gcr.io"];
        data-root = "/home/${vars.PRIMARY_USER.NAME}/.local/state/docker-data";
      };
    };
  };

  # users.users.${vars.PRIMARY_USER.NAME}.extraGroups = ["docker"];
}
