{
  inputs,
  l,
  ...
}: {
  flake.vms = {
    Helium = l.mkNixosSystem [
      inputs.microvm.nixosModules.microvm
      (
        {pkgs, ...}: {
          nixpkgs.hostPlatform = "x86_64-linux";
          networking.hostName = "Helium";
          system.stateVersion = l.mkDefault "24.11";

          microvm = {};

          services.getty.autologinUser = "root";

          environment.systemPackages = with pkgs; [
            vim
            htop
          ];

          users = {
            mutableUsers = false;
            enforceIdUniqueness = true;
            allowNoPasswordLogin = true;
            # users.root.hashedPassword = "!"; # Disables login for the root user

            # users.nixos = {
            #   isNormalUser = true;
            #   createHome = true;
            #   useDefaultShell = false;
            #   password = "abc123";
            #   group = "users";
            #   extraGroups = [ "wheel" ];

            #   openssh.authorizedKeys.keys = [
            #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFlro/QUDlDpaA1AQxdWIqBg9HSFJf9Cb7CPdsh0JN7"
            #   ];
            # };
          };
        }
      )
    ];
  };
}
