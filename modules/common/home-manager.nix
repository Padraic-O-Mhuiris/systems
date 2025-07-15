{
  inputs,
  vars,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = false;
    backupFileExtension = "backup";
    verbose = true;
  };

  users.${vars.PRIMARY_USER.NAME} = {osConfig, ...}: {
    inherit (osConfig.system) stateVersion;
  };
}
