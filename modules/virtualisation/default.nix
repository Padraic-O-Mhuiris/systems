{vars, ...}: {
  virtualisation.docker.enable = true;
  users.users.${vars.PRIMARY_USER.NAME}.extraGroups = ["docker"];
}
