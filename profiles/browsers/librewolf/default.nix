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

  home-manager.users.${vars.users.primary.name} = {
    config,
    pkgs,
    ...
  }: let
    # Custom LibreWolf package with userChrome.js support (using stable nixpkgs)
    pkgs-stable = import inputs.nixpkgs-stable {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
    customLibrewolfPkg = import ./package.nix {inherit pkgs pkgs-stable;};
    shared = {
      extensions = {
        force = false;
        packages = import ./extensions.nix {inherit (pkgs.nur.repos.rycee) firefox-addons;};
      };
      settings = import ./settings.nix {inherit pkgs;};
      userChrome = ''
        /* Hide Firefox Sync button */
        #fxa-toolbar-menu-button { display: none !important; }
        /* Hide password manager menu items */
        #appMenu-passwords-button { display: none !important; }
        #PanelUI-passwords-button { display: none !important; }
        /* Hide home button */
        #home-button { display: none !important; }
      '';
    };
  in {
    home.sessionVariables."BROWSER" = pkgs.lib.getExe config.programs.librewolf.package;

    # Deploy userChrome.js scripts and loader utilities to profile directories
    # NOTE: config.js and config-prefs.js are injected into the LibreWolf installation
    # via package.nix, NOT into the profile
    home.file = let
      # Symlink to allow live editing of scripts without rebuilding
      JSsrcPath = "/home/${vars.users.primary.name}/systems/profiles/browsers/librewolf/userchrome/scripts";
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
        Bookmarks = [
          {
            Title = "YouTube";
            URL = "https://youtube.com";
            Placement = "menu";
          }
          {
            Title = "Gmail";
            URL = "https://gmail.com";
            Placement = "menu";
          }
          {
            Title = "GitHub";
            URL = "https://github.com";
            Placement = "menu";
          }
          {
            Title = "Lobsters";
            URL = "https://lobste.rs";
            Placement = "menu";
          }
        ];
        BlockAboutAddons = false;
        BlockAboutConfig = true;
        BlockAboutProfiles = false;
        BlockAboutSupport = false;
        PasswordManagerEnabled = false;
      };
      profiles."${config.home.username}" =
        {
          id = 0;
          isDefault = true;
          name = config.home.username;
        }
        // shared;
      # profiles."work" =
      #   {
      #     id = 1;
      #     isDefault = false;
      #     name = "work";
      #   }
      #   // shared;
    };
  };
}
