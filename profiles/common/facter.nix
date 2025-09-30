{
  config,
  inputs,
  root,
  ...
}: {
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
  ];

  facter.reportPath = root + "/hosts/${config.networking.hostName}/facter.json";
}
