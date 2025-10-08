{vars, ...}: {
  # virtualisation = {
  #   containers.enable = true;
  #   podman = {
  #     enable = true;
  #     # autoPrune = true;
  #     # Create a `docker` alias for podman, to use it as a drop-in replacement
  #     dockerCompat = true;
  #     # Required for containers under podman-compose to be able to talk to each other.
  #     defaultNetwork.settings.dns_enabled = true;
  #   };

  #   oci-containers.backend = "podman";
  # };
  virtualisation.docker = {
    enable = true;
    # Customize Docker daemon settings using the daemon.settings option
    daemon.settings = {
      dns = ["1.1.1.1" "8.8.8.8"];
      log-driver = "journald";
      registry-mirrors = ["https://mirror.gcr.io"];
      storage-driver = "overlay2";
      # Do not have enough storage state in root
      data-root = "/home/${vars.PRIMARY_USER.NAME}/.local/state/docker-data";
    };
    # Use the rootless mode - run Docker daemon as non-root user
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  users.users.${vars.PRIMARY_USER.NAME}.extraGroups = ["docker"];

  # K3s needs access
  # boot.kernelParams = ["cgroup_enable=memory" "cgroup_enable=cpuset" "cgroup_memory=1"];

  # Allows k3s to delegate user control over system resources
  systemd.services."user@".serviceConfig = {
    Delegate = "cpu cpuset io memory pids";
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
}
