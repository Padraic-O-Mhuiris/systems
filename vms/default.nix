{ inputs, l, ... }:
{
  flake.vms = {
    Helium = l.mkNixosSystem [
      inputs.microvm.nixosModules.microvm
      (
        { pkgs, ... }:
        {
          nixpkgs.hostPlatform = "x86_64-linux";
          networking.hostName = "HeliumVM";
          system.stateVersion = l.mkDefault "24.11";

          users = {
            mutableUsers = false;
            enforceIdUniqueness = true;
            users.root.hashedPassword = "!"; # Disables login for the root user

            users.padraic = {
              isNormalUser = true;
              createHome = true;
              useDefaultShell = false;

              # passwordFile = config.sops.secrets."user@${name}".path;
              # TODO Figure out why sops is not working for this on first installation?
              hashedPassword = "$6$7RhoYiLu0Xn50HZD$pOIypZUz6aALwRt4SlsckKmTFo0r6fHh5zbSTLBQGkrPuoJS.7bJirx936XensJSlkn0e472nKjzE7Y4tv7td0";
              group = "users";
              extraGroups = [
                "wheel"
                "input"
                "networkmanager"
                "audio"
                "pipewire"
                "video"
                "docker"
              ];
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFlro/QUDlDpaA1AQxdWIqBg9HSFJf9Cb7CPdsh0JN7"
              ];
            };

          };
        }
      )
    ];
  };
}
