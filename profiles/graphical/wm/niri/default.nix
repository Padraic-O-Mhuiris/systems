{
  pkgs,
  inputs,
  vars,
  ...
}: {
  imports = [
    inputs.niri.nixosModules.niri
    ./waybar.nix
    ./swaylock.nix
    ./mako.nix
    # ./wezterm-toggle.nix
  ];

  services.displayManager.defaultSession = "niri";

  niri-flake.cache.enable = true;
  programs.niri.enable = true;
  nixpkgs.overlays = [inputs.niri.overlays.niri];
  programs.niri.package = pkgs.niri-unstable;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config.niri = {
      default = "gnome";
      "org.freedesktop.impl.portal.ScreenCast" = "gnome";
      "org.freedesktop.impl.portal.Screenshot" = "gnome";
    };
  };

  environment.variables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayland-utils
    wayland-protocols
    libsecret
    cage
    wlr-randr
    gamescope
    xwayland-satellite-unstable
    swaybg

    wf-recorder
  ];

  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [brightnessctl gammastep];

    home.sessionVariables = {
      LAUNCHER = "${lib.getExe pkgs.fuzzel}";
    };

    programs.niri.settings = {
      animations.enable = false;
      hotkey-overlay.skip-at-startup = true;

      spawn-at-startup = [
        {command = ["xwayland-satellite"];}
        {command = ["waybar"];}
        {
          command = ["niri" "msg" "action" "focus-workspace-down"];
        }
      ];
      prefer-no-csd = true;

      environment = {
        "DISPLAY" = ":0";
      };

      cursor = {
        theme = "default";
        hide-when-typing = true;
      };

      overview = {
        zoom = 0.5;
        # backdrop-color = "#${defaults.colorScheme.palette.base02}";
        # TODO: implement and submit PR to niri-flake
        # workspace-shadow = false;
      };

      layout = {
        gaps = 16;
        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };

        focus-ring = {
          enable = true;
          width = 3;
          # active.color = "#${defaults.colorScheme.palette.base0D}";
          # inactive.color = "#${defaults.colorScheme.palette.base02}";
        };

        border = {
          enable = true;
          width = 1;
          # active.color = "#${defaults.colorScheme.palette.base02}";
          # inactive.color = "#${defaults.colorScheme.palette.base02}";
        };

        insert-hint = {
          enable = true;
          # display.color = "rgb(${nix-colors.lib-core.conversions.hexToRGBString " " defaults.colorScheme.palette.base0D} / 50%)";
        };

        default-column-width.proportion = 0.5;
        preset-column-widths = [
          {proportion = 0.25;}
          {proportion = 0.50;}
          {proportion = 0.75;}
          {proportion = 1.0;}
        ];

        # center-focused-column = "always";
        # always-center-single-column = true;
      };

      input = {
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
        warp-mouse-to-focus = {
          enable = true;
          mode = "center-xy";
        };
        keyboard.xkb = {
          layout = "gb";
          options = "ctrl:nocaps";
        };
      };

      binds = let
        inherit
          (config.lib.niri.actions)
          close-window
          maximize-column
          fullscreen-window
          toggle-overview
          quit
          spawn
          focus-column-or-monitor-left
          move-column-left-or-to-monitor-left
          focus-column-or-monitor-right
          move-column-right-or-to-monitor-right
          focus-window-or-workspace-down
          move-window-down-or-to-workspace-down
          focus-window-or-workspace-up
          move-window-up-or-to-workspace-up
          # move-window-to-monitor-left
          # move-window-to-monitor-right
          ;
      in {
        "Mod+D" = {
          action = spawn "${config.home.sessionVariables.LAUNCHER}";
          repeat = false;
        };

        "Mod+Alt+L".action = spawn "swaylock";

        "Mod+Shift+E".action = quit;

        "Mod+Left".action = focus-column-or-monitor-left;
        "Mod+H".action = focus-column-or-monitor-left;
        "Mod+Shift+Left".action = move-column-left-or-to-monitor-left;
        "Mod+Shift+H".action = move-column-left-or-to-monitor-left;

        "Mod+Right".action = focus-column-or-monitor-right;
        "Mod+L".action = focus-column-or-monitor-right;
        "Mod+Shift+Right".action = move-column-right-or-to-monitor-right;
        "Mod+Shift+L".action = move-column-right-or-to-monitor-right;

        "Mod+Down".action = focus-window-or-workspace-down;
        "Mod+J".action = focus-window-or-workspace-down;
        "Mod+Shift+Down".action = move-window-down-or-to-workspace-down;
        "Mod+Shift+J".action = move-window-down-or-to-workspace-down;

        "Mod+Up".action = focus-window-or-workspace-up;
        "Mod+K".action = focus-window-or-workspace-up;
        "Mod+Shift+Up".action = move-window-up-or-to-workspace-up;
        "Mod+Shift+K".action = move-window-up-or-to-workspace-up;

        "Mod+Space".action = toggle-overview;

        "Mod+Q".action = close-window;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;

        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;

        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+9".action.move-column-to-workspace = 9;
      };
    };
  };
}
