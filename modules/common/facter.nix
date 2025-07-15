{
  config,
  inputs,
  root,
  ...
}: {
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
  ];

  facter.reportPath = root + "host/${config.networking.hostName}" + ./facter.json;
}
