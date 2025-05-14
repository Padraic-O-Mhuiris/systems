{vars, ...}: {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {config, ...}: {
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
  };
}
