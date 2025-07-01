{
  inputs,
  vars,
  ...
}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {pkgs, ...}: {
    imports = [
      inputs.zen-browser.homeModules.beta
    ];

    programs.zen-browser = {
      enable = true;
      nativeMessagingHosts = [pkgs.firefoxpwa];
      policies = {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        ExtensionSettings = let
          old-reddit-redirect = "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}";
          metamask = "webextension@metamask.io";
          ublock-origin = "uBlock0@raymondhill.net";
          i-dont-care-about-cookies = "jid1-KKzOGWgsW3Ao4Q@jetpack";
          harvest = "support@harvestapp.com";
          bitwarden = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
        in {
          "${old-reddit-redirect}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4468297/old_reddit_redirect-2.0.5.xpi";
            installation_mode = "force_installed";
          };
          "${metamask}" = {
            install_url = "https://github.com/MetaMask/metamask-extension/releases/download/v12.17.3/metamask-firefox-12.17.3.zip";
            installation_mode = "force_installed";
          };
          "${ublock-origin}" = {
            install_url = "https://github.com/gorhill/uBlock/releases/download/1.64.0/uBlock0_1.64.0.firefox.signed.xpi";
            installation_mode = "force_installed";
          };
          "${i-dont-care-about-cookies}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4172206/i_dont_care_about_cookies-3.5.0.xpi";
            installation_mode = "force_installed";
          };
          "${harvest}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4428389/harvest_time_tracker-3.1.16.xpi";
            installation_mode = "force_installed";
          };
          "${bitwarden}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4484791/bitwarden_password_manager-2025.5.0.xpi";
            installation_mode = "force_installed";
          };
        };
        Preferences = let
          locked = value: {
            "Value" = value;
            "Status" = "locked";
          };
        in {
          "browser.tabs.warnOnClose" = locked false;
          "browser.shell.checkDefaultBrowser" = locked false;
          "layers.acceleration.force-enabled" = locked true;
        };
      };
    };
  };
}
