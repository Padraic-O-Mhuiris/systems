{
  config,
  inputs,
  pkgs,
  root,
  ...
}: {
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
  ];

  facter.reportPath = root + "/hosts/${config.networking.hostName}/facter.json";

  environment.systemPackages = with pkgs; [dmidecode lshw];
}
