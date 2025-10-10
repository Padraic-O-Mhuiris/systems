{
  vars,
  pkgs,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {osConfig, ...}: let
    flakePath = "$HOME/systems";
    host = osConfig.networking.hostName;
  in {
    home = {
      packages = with pkgs; [nh];

      shellAliases = {
        nr = "${pkgs.nh}/bin/nh os switch ${flakePath} -H ${host}";
        nrd = "sudo nixos-rebuild --flake ${flakePath}#${host} switch --show-trace --verbose --print-build-logs";
      };
    };
  };
}
