{
  vars,
  pkgs,
  ...
}: let
  getFocusedMonitorScript = pkgs.writeShellScript "get-focused-monitor" ''
    #!/bin/sh
    focused_monitor=$(${pkgs.niri}/bin/niri msg -j focused-output 2>/dev/null | ${pkgs.jq}/bin/jq -r '.name')

    if [ "$focused_monitor" = "Unknown" ] || [ -z "$focused_monitor" ]; then
        echo "No Monitor"
        exit 0
    fi

    case "$focused_monitor" in
        "HDMI-A-1")
            echo "[1] 2"
            ;;
        "DP-1")
            echo "1 [2]"
            ;;
        *)
            echo "🖥️ $focused_monitor"
            ;;
    esac
  '';
in {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {pkgs, ...}: {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          spacing = 4;

          modules-left = [
            "custom/spacer"
            "custom/focused-monitor"
          ];
          modules-center = ["clock"];
          modules-right = ["pulseaudio" "network" "battery" "tray"];

          "custom/focused-monitor" = {
            format = "{}";
            max-length = 50;
            interval = 1;
            exec = getFocusedMonitorScript;
            return-type = "string";
          };

          clock = {
            timezone = "Europe/Dublin";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            format-icons = ["" "" "" "" ""];
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };

          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };

          tray = {
            spacing = 10;
          };
        };
      };

      # Optional: Add basic styling
      style =
        #css
        ''
          * {
            border: none;
            border-radius: 0;
            font-family: "JetBrains Mono", monospace;
            font-size: 13px;
            min-height: 0;
          }

          window#waybar {
            background-color: rgba(43, 48, 59, 0.8);
            border-bottom: 3px solid rgba(100, 114, 125, 0.5);
            color: #ffffff;
          }

          #workspaces button {
            padding: 0 5px 0 5px;
            background-color: transparent;
            color: #ffffff;
          }

          #workspaces button.focused {
            background-color: rgba(0, 0, 0, 0.3);
            box-shadow: inset 0 -3px #ffffff;
          }

          #custom-spacer {
            min-width: 10px;
            background: transparent;
          }

          #clock,
          #battery,
          #cpu,
          #memory,
          #disk,
          #temperature,
          #backlight,
          #network,
          #pulseaudio,
          #custom-media,
          #tray,
          #mode,
          #idle_inhibitor,
          #custom-focused-monitor,
          #mpd {
            padding: 0 5px 0 5px;
            color: #ffffff;
          }
        '';
    };
  };
}
