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

    users.${vars.users.primary.name} = {osConfig, ...}: {
      home = {
        inherit (osConfig.system) stateVersion;
      };
    };
  };
}
