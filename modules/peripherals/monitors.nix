{
  pkgs,
  vars,
  ...
}: {
  # TODO This does not work on Oxygen monitors
  environment.systemPackages = with pkgs; [
    ddcutil
    wlr-randr
  ];
  boot.kernelModules = ["i2c-dev"];
  users.users.${vars.PRIMARY_USER.NAME}.extraGroups = ["i2c"];
}
