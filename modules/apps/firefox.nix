{
  inputs,
  vars,
  # config,
  pkgs,
  ...
}: let
  package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    extraPolicies = {
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;
      BlockAboutAddons = false;
      BlockAboutConfig = false;
      BlockAboutProfiles = true;
      BlockAboutSupport = true;
      Bookmarks = [];
      CaptivePortal = false;
      # DefaultDownloadDirectory = config.xdg.userDirs.download;
      DisableAppUpdate = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableFirefoxScreenshots = true;
      DisableForgetButton = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisplayBookmarksToolbar = "never";
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      PasswordManagerEnabled = false;
      HardwareAcceleration = true;
      InstallAddonsPermission = {
        Default = true;
      };
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        CryptoMining = true;
        Fingerprinting = false; # This messes with time
        EmailTracking = true;
      };
      FirefoxHome = {
        Search = true;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponseredPocked = false;
        Snippets = false;
        Locked = true;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        SkipOnboarding = true;
      };
      Homepage = {
        Locked = true;
        StartPage = "none";
      };
    };
  };

  search = {
    default = "google";
    force = true;
    engines = {
      "Nix Packages" = {
        urls = [
          {
            template = "https://search.nixos.org/packages";
            params = [
              {
                name = "type";
                value = "packages";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@np"];
      };
      "NixOS Options" = {
        urls = [
          {
            template = "https://search.nixos.org/options";
            params = [
              {
                name = "type";
                value = "options";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@no"];
      };
      "HomeManager Options" = {
        urls = [
          {
            template = "https://mipmip.github.io/home-manager-option-search/";
            params = [
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = ["@nho"];
      };
    };
  };

  extensions = {
    packages = with pkgs.nur.repos.rycee.firefox-addons; [
      ublock-origin
      metamask
      bitwarden
      old-reddit-redirect
      i-dont-care-about-cookies
      reddit-enhancement-suite
    ];
  };

  settings = {
    "browser.aboutConfig.showWarning" = false;
    "browser.shell.checkDefaultBrowser" = false;
    "browser.tabs.tabMinWidth" = 66;
    "browser.tabs.tabClipWidth" = 86;
    "browser.tabs.tabmanager.enabled" = false;
    "browser.tabs.firefox-view" = false;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "layers.acceleration.force-enabled" = true;
    "gfx.webrender.all" = true;
    "svg.context-properties.content.enabled" = true;
    "network.protocol-handler.external.zoommtg" = true; # Needed for zoom
  };
in {
  nixpkgs.overlays = [
    inputs.nur.overlays.default
  ];

  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
    programs.firefox = {
      enable = true;
      inherit package;
      profiles."${config.home.username}" = {
        id = 0;
        isDefault = true;
        name = config.home.username;
        inherit search extensions settings;
      };
    };

    home.sessionVariables."BROWSER" = pkgs.lib.getExe package;
  };
}
