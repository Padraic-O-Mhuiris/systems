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
    extensionPackages =
      # NOTE Ublock origin is preinstalled in librewolf
      with pkgs.nur.repos.rycee.firefox-addons; [
        # Local sourced cookies
        cookies-txt
        # This add-on stops websites from blocking copy and paste for password fields and other input fields.
        don-t-fuck-with-paste
        # Create userscripts easily
        greasemonkey
        # Rewrites urls to open-source, free alternatives
        libredirect
        # Redirects third-party cdn requests to localstorage
        localcdn
        #
        return-youtube-dislikes
        # community listed sponsoring blocking
        sponsorblock
        # Free articles
        unpaywall
        # Block youtube shorts
        youtube-shorts-block

        # Crypto wallet
        metamask
        # Passwords Management
        bitwarden
        # Prefer old reddit
        old-reddit-redirect
        # Enhance reddit
        reddit-enhancement-suite
        # No cookies - community version
        istilldontcareaboutcookies
        # Blocks hidden-trackers
        privacy-badger
        # Changes colour of firefox theme to websites colour
        adaptive-tab-bar-colour
        # Use anonymous email forwarding
        addy_io

        # Use windows instead of tabs
        # adsum-notabs

        # Jumps through link-shorteners
        fastforwardteam
        # File icons for github
        github-file-icons
        # Enforce more performant video codec for youtube for <1440p quality
        h264ify
        # Price charts on Amazon
        keepa

        # TODO Get a link archiver

        # command launcher
        omnisearch
        # Watch/listen streams in vlc
        open-in-vlc
        # Github improvements
        refined-github
        # Image search
        search-by-image
        # TOS
        terms-of-service-didnt-read

        # vim motions
        # https://wiki.csgalileo.org/tips/tridactyl
        tridactyl

        # Website history
        web-archives
        # block canvas
        canvasblocker
      ];

    policies = {
      Bookmarks = [];
      BlockAboutAddons = false;
      BlockAboutConfig = true;
      BlockAboutProfiles = false;
      BlockAboutSupport = true;
    };

    settings = {
      # https://librewolf.net/docs/settings/#enable-google-safe-browsing
      "browser.safebrowsing.malware.enabled" = true;
      "browser.safebrowsing.phishing.enabled" = true;
      "browser.safebrowsing.blockedURIs.enabled" = true;
      "browser.safebrowsing.provider.google4.gethashURL" = "htps://safebrowsing.googleapis.com/v4/fullHashes:find?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST";
      "browser.safebrowsing.provider.google4.updateURL" = "htps://safebrowsing.googleapis.com/v4/threatListUpdates:fetch?$ct=application/x-protobuf&key=%GOOGLE_SAFEBROWSING_API_KEY%&$httpMethod=POST";
      "browser.safebrowsing.provider.google.gethashURL" = "htps://safebrowsing.google.com/safebrowsing/gethash?client=SAFEBROWSING_ID&appver=%MAJOR_VERSION%&pver=2.2";
      "browser.safebrowsing.provider.google.updateURL" = "htps://safebrowsing.google.com/safebrowsing/downloads?client=SAFEBROWSING_ID&appver=%MAJOR_VERSION%&pver=2.2&key=%GOOGLE_SAFEBROWSING_API_KEY%";

      # Enable userChrome.css
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

      "accessibility.force_disabled" = 1;
      "browser.shell.checkDefaultBrowser" = false;
      "browser.tabs.firefox-view" = false;

      # Prevents clearing out cookie site data
      "privacy.sanitize.sanitizeOnShutdown" = false;
      # Enables all user installed extensions
      "extensions.autoDisableScopes" = 0;
      # Don't show bookmarks bar
      "browser.toolbars.bookmarks.visibility" = "never";
      "browser.newtabpage.enabled" = false;
      "browser.quitShortcut.disabled" = true;
      "browser.search.suggest.enabled" = true;
      "general.autoScroll" = true;
      "middlemouse.paste" = false;
      "spellchecker.dictionary_path" = pkgs.symlinkJoin {
        name = "firefox-hunspell-dicts";
        paths = with pkgs.hunspellDicts; [en-gb-large];
      };
      "widget.content.allow-gtk-dark-theme" = true;

      # user agent and overall behavioral tweaks
      "gfx.webrender.all" = true;
      "general.useragent.compatMode.firefox" = true;
      "image.jxl.enabled" = true;
      "noscript.sync.enabled" = true;
      "privacy.donottrackheader.enabled" = true;
      "webgl.disabled" = false;
      "xpinstall.signatures.required" = false;

      # privacy tweaks
      "browser.contentblocking.category" = "strict";
      "intl.accept_languages" = "en-US, en";
      "javascript.use_us_english_locale" = true;
      # https://github.com/tridactyl/tridactyl/blob/master/doc/troubleshooting.md#firefox-settings-that-can-break-tridactyl
      "privacy.resistFingerprinting" = false;
      "network.cookie.lifetimePolicy" = 0;
      "privacy.clearOnShutdown.cache" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown.downloads" = false;
      "privacy.clearOnShutdown.formdata" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.offlineApps" = false;
      "privacy.clearOnShutdown.sessions" = false;
      "privacy.fingerprintingProtection" = true;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.emailtracking.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;

      # Causes screen to reshape
      "privacy.resistFingerprinting.letterboxing" = false;
    };

    userChrome = ''
      /* Hide tab bar */
      #TabsToolbar {
        visibility: collapse !important;
      }
    '';
  in {
    home.sessionVariables."BROWSER" = pkgs.lib.getExe config.programs.librewolf.package;

    programs.librewolf = {
      enable = true;
      languagePacks = ["en-GB" "en-US" "ga-IE"];
      inherit policies;

      profiles."work" = {
        id = 1;
        isDefault = false;
        name = "work";
        inherit settings userChrome;
        extensions = {
          force = true;
          packages = extensionPackages;
        };
      };
      profiles."${config.home.username}" = {
        id = 0;
        isDefault = true;
        name = config.home.username;
        search = {
          force = true;
          default = "ddg";
        };
        extensions = {
          force = true;
          packages = extensionPackages;
        };
        inherit settings userChrome;
      };
    };
  };
}
