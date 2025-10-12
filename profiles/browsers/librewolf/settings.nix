{pkgs}: {
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
}
