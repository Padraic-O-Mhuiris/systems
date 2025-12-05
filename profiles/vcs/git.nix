{
  pkgs,
  vars,
  ...
}: {
  home-manager.users.${vars.users.primary.name} = _: {
    home.packages = with pkgs; [lazygit];

    home.shellAliases."lg" = "${pkgs.lazygit}/bin/lazygit";

    programs.git = {
      enable = true;
      signing.signByDefault = true;
      signing.key = vars.pubkeys.gpg.primary.fingerprint;
      ignores = [".direnv"];
      settings.user = {
        email = vars.users.primary.email;
        name = vars.users.primary.fullName;
      };
    };
  };
}
