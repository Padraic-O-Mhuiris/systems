{
  pkgs,
  vars,
  ...
}: {
  programs.hyprland = {
    enable = true;
  };

  home-manager.users.${vars.users.primary.name} = {
    config,
    lib,
    ...
  }: {
    home.packages = with pkgs; [
      pyprland
      wofi
    ];
    home.sessionVariables = {
      LAUNCHER = "${lib.getExe config.programs.wofi.package} --show drun -I";
      NIXOS_OZONE_WL = "1";
    };

    programs.waybar = {
      enable = true;
      settings = {
        main = {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = ["hyprland/workspaces"];
          modules-center = ["hyprland/window"];
          modules-right = ["network" "battery" "clock" "tray"];

          # Module configuration
          "hyprland/workspaces" = {
            format = "{name}";
            on-click = "activate";
          };
          "clock" = {
            format = "{:%H:%M}";
            tooltip-format = "{:%Y-%m-%d | %H:%M}";
          };
          "battery" = {
            format = "{capacity}% {icon}";
            format-icons = ["" "" "" "" ""];
          };
          "network" = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            format-disconnected = "Disconnected ";
          };
        };
      };
    };

    xdg.configFile."hypr/pyprland.toml".text = ''
      [pyprland]
      plugins = [
       "expose",
       "fetch_client_menu",
       "lost_windows",
       "magnify",
       "scratchpads",
       "shift_monitors",
       "toggle_special",
       "workspaces_follow_focus",
      ]

      # using variables for demonstration purposes (not needed)
      [pyprland.variables]
      term_classed = "${config.home.sessionVariables.TERMINAL} start --class"

      [scratchpads.term]
      command = "[term_classed] main-dropterm"
      class = "main-dropterm"
      position = "0% 30px"
      size = "100% 100%"
      max_size = "100% 100%"
      multi = false
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "SUPER";

        input = {
          kb_layout = "gb";
          kb_options = "ctrl:nocaps";
        };
        animations = {
          enabled = false;
        };
        bind =
          [
            "$mod SHIFT, E, exec, pkill Hyprland"
            "$mod, q, killactive,"
            "$mod, f, fullscreen,"
            "$mod, d, exec, ${config.home.sessionVariables.LAUNCHER}"
            "$mod, x, exec, pypr toggle term "
          ]
          ++ (
            builtins.concatLists (builtins.genList (
                i: let
                  ws = i + 1;
                in [
                  "$mod, code:1${toString i}, workspace, ${toString ws}"
                  "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              )
              9)
          );
        exec-once = [
          "pypr --debug /tmp/pypr.log"
          "waybar"
        ];
      };
    };
  };
}
