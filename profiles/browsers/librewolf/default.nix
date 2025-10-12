# - https://github.com/pierrot-lc/librewolf-nix
# - https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265
# - https://librewolf.net/docs/settings/
# - https://github.com/chayleaf/dotfiles/blob/543611983cd66449378ada55e33d6d0bff7a6e55/home/modules/firefox.nix#L8
# TODO Firefox containers for major websites
{
  vars,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.nur.overlays.default
  ];

  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    pkgs,
    ...
  }: let
    shared = {
      extensions = {
        force = true;
        packages = import ./extensions.nix {inherit (pkgs.nur.repos.rycee) firefox-addons;};
      };
      settings = import ./settings.nix {inherit pkgs;};
      userChrome = ''
      '';
    };
  in {
    home.sessionVariables."BROWSER" = pkgs.lib.getExe config.programs.librewolf.package;

    programs.librewolf = {
      enable = true;
      languagePacks = ["en-GB" "en-US" "ga-IE"];
      policies = {
        Bookmarks = [];
        BlockAboutAddons = false;
        BlockAboutConfig = true;
        BlockAboutProfiles = false;
        BlockAboutSupport = true;
      };
      profiles."${config.home.username}" =
        {
          id = 0;
          isDefault = true;
          name = config.home.username;
        }
        // shared;
      profiles."work" =
        {
          id = 1;
          isDefault = false;
          name = "work";
        }
        // shared;
    };
  };
}
