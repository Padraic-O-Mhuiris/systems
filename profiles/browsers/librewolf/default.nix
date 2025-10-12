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
    # Custom LibreWolf package with userChrome.js support
    customLibrewolfPkg = import ./package.nix {inherit pkgs;};
    shared = {
      extensions = {
        force = false;
        packages = import ./extensions.nix {inherit (pkgs.nur.repos.rycee) firefox-addons;};
      };
      settings = import ./settings.nix {inherit pkgs;};
      userChrome = ''
      '';
    };
  in {
    home.sessionVariables."BROWSER" = pkgs.lib.getExe config.programs.librewolf.package;

    # Deploy userChrome.js scripts and loader utilities to profile directories
    # NOTE: config.js and config-prefs.js are injected into the LibreWolf installation
    # via package.nix, NOT into the profile
    home.file = let
      # Symlink to allow live editing of scripts without rebuilding
      JSsrcPath = "/home/${vars.PRIMARY_USER.NAME}/systems/profiles/browsers/librewolf/userchrome/scripts";
    in {
      # Main profile - utils loader and scripts
      ".librewolf/${config.home.username}/chrome/utils" = {
        source = ./userchrome/utils;
        recursive = true;
      };
      ".librewolf/${config.home.username}/chrome/JS" = {
        source = config.lib.file.mkOutOfStoreSymlink JSsrcPath;
      };

      # Work profile - utils loader and scripts
      ".librewolf/work/chrome/utils" = {
        source = ./userchrome/utils;
        recursive = true;
      };
      ".librewolf/work/chrome/JS" = {
        source = config.lib.file.mkOutOfStoreSymlink JSsrcPath;
        recursive = true;
      };
    };

    programs.librewolf = {
      enable = true;
      package = customLibrewolfPkg;
      languagePacks = ["en-GB" "en-US" "ga-IE"];
      policies = {
        Bookmarks = [];
        BlockAboutAddons = false;
        BlockAboutConfig = true;
        BlockAboutProfiles = false;
        BlockAboutSupport = false;
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
