{vars, ...}: {
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      # autoPrune = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers.backend = "podman";
  };

  # virtualisation.docker = {
  #   enable = false;
  #   rootless = {
  #     enable = true;
  #     setSocketVariable = true;
  #     # Optionally customize rootless Docker daemon settings
  #     daemon.settings = {
  #       dns = ["1.1.1.1" "8.8.8.8"];
  #       registry-mirrors = ["https://mirror.gcr.io"];
  #       data-root = "/home/${vars.PRIMARY_USER.NAME}/.local/state/docker-data";
  #     };
  #   };
  # };

  users.users.${vars.PRIMARY_USER.NAME}.extraGroups = ["podman"];
}
