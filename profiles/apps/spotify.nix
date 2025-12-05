{vars, ...}: {
  home-manager.users.${vars.users.primary.name} = {pkgs, ...}: {
    home.packages = [
      pkgs.spotify
      # TODO The below is some failed workings on the annoying keyring popup. This is consequential of
      # the source being installed from snapcraft and doing some internal jangling. There may be some
      # env fixes which may help but needs investigation
      #
      # (pkgs.symlinkJoin {
      #   name = "spotify";
      #   paths = [pkgs.spotify];
      #   buildInputs = [pkgs.makeWrapper];
      #   postBuild = ''
      #     wrapProgram $out/bin/spotify \
      #       --set DBUS_FATAL_WARNINGS 0 \
      #       --add-flags "--password-store=basic"
      #   '';
      # })
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [57621];
    allowedUDPPorts = [5353];
  };
}
