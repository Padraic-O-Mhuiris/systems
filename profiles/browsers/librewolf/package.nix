# Custom LibreWolf package with autoconfig support for userChrome.js script loader
# Based on: https://github.com/xiaoxiaoflood/firefox-scripts
# See: https://github.com/xiaoxiaoflood/firefox-scripts/issues/8#issuecomment-467619800
{pkgs}: let
  autoconfigFiles = {
    # Main config file that loads the userChrome.js system
    config = ./userchrome/autoconfig/config.js;
    # Preferences that tell Firefox to load config.js
    prefs = ./userchrome/autoconfig/config-prefs.js;
  };

  # Standard wrapped LibreWolf
  basePackage = pkgs.wrapFirefox pkgs.librewolf-unwrapped {
    inherit (pkgs.librewolf-unwrapped) extraPrefsFiles extraPoliciesFiles;
    wmClass = "LibreWolf";
    libName = "librewolf";
    nativeMessagingHosts = with pkgs; [keepassxc];
  };
in
  # Override the wrapper to inject autoconfig files into the installation directory
  # Firefox autoconfig requires:
  #   - config.js at $out/lib/librewolf/config.js
  #   - config-prefs.js at $out/lib/librewolf/browser/defaults/preferences/config-prefs.js
  basePackage.overrideAttrs (oldAttrs: {
    buildCommand =
      oldAttrs.buildCommand
      + ''
        # Inject userChrome.js autoconfig loader
        # config.js: Main autoconfig script that bootstraps the loader
        install -Dm644 ${autoconfigFiles.config} $out/lib/librewolf/config.js

        # config-prefs.js: Preferences that enable autoconfig
        install -Dm644 ${autoconfigFiles.prefs} $out/lib/librewolf/browser/defaults/preferences/config-prefs.js
      '';
  })
