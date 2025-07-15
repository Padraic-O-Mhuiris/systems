{
  vars,
  lib,
  ...
}: {
  services.xserver = {
    xkb = {
      options = "ctrl:swapcaps";
      layout = lib.mkDefault "gb";
    };
  };
  console.useXkbConfig = true;

  users.users."${vars.PRIMARY_USER.NAME}".extraGroups = ["input"];
}
