{
  vars,
  pkgs,
  ...
}: let
  weztermApplicationId = "wezterm-toggle-terminal";
  weztermWorkspace = "terminal";
  weztermToggleScript = pkgs.writeShellScriptBin "weztermToggle" ''
    WEZTERM_APP_ID="${weztermApplicationId}"
    WEZTERM_STATE_FILE="/tmp/wezterm-state"

    if [ ! -f "$WEZTERM_STATE_FILE" ]; then
      touch "$WEZTERM_STATE_FILE"
    fi

    set -x

    windows=$(niri msg -j windows | jq)
    workspaces=$(niri msg -j workspaces | jq)
    active_workspaces=$(echo $workspaces | jq -r '.[] | select(.is_active == true)')

    focused_window=$(echo $windows | jq -r '.[] | select(.is_focused == true)')
    focused_window_id=$(echo $focused_window | jq -r '.id')
    focused_workspace_id=$(echo $focused_window | jq -r '.workspace_id')
    focused_workspace=$(echo $workspaces | jq -r --arg workspace_id "$focused_workspace_id" '.[] | select(.id == ($workspace_id | tonumber))')
    focused_monitor_name=$(echo $focused_workspace | jq -r '.output')
    focused_monitor=$(niri msg -j outputs | jq -r --arg monitor "$focused_monitor_name" '.[] | select(.name == $monitor) | .logical')

    focused_monitor_width=$(echo $focused_monitor | jq -r ".width")
    focused_monitor_height=$(echo $focused_monitor | jq -r ".height")

    prev_focused_window_id=""
    prev_focused_workspace_id=""
    prev_focused_monitor_name=""

    terminal_workspace=$(echo $workspaces | jq -r '.[] | select(.name == "${weztermWorkspace}")')
    if [ -z "$terminal_workspace" ]; then
        notify-send "Terminal Launch Failed" "No workspace named ${weztermApplicationId}"
        exit 1
    fi
    terminal_workspace_id=$(echo $terminal_workspace | jq -r '.id')

    terminal_exists=$(echo "$windows" | jq -r --arg app_id "$WEZTERM_APP_ID" '.[] | select(.app_id == $app_id) | .app_id' | head -1)
    if [ -z "$terminal_exists" ]; then
        ${pkgs.wezterm}/bin/wezterm start --class "$WEZTERM_APP_ID" &

        timeout=10
        count=0

        while [ $count -lt $timeout ]; do
            current_windows=$(niri msg -j windows)
            terminal_spawned=$(echo "$current_windows" | jq -r --arg app_id "$WEZTERM_APP_ID" '.[] | select(.app_id == $app_id) | .app_id' | head -1)

            if [ -n "$terminal_spawned" ]; then
                windows="$current_windows"
                break
            fi

            sleep 0.1
            count=$((count + 1))
        done

        if [ $count -eq $timeout ]; then
            notify-send "Terminal Launch Failed" "Wezterm failed to spawn within 1 second"
            exit 1
        fi
    fi

    terminal_window=$(echo $windows | jq -r --arg app_id "$WEZTERM_APP_ID" '.[] | select(.app_id == $app_id)')
    terminal_window_id=$(echo $terminal_window | jq -r '.id')
    terminal_window_is_focused=$(echo $terminal_window | jq -r '.is_focused')
    terminal_window_is_floating=$(echo $terminal_window | jq -r '.is_floating')
    terminal_workspace_is_active=$(echo $active_workspaces | jq -r --arg workspace_id $terminal_workspace_id 'select(.id == $workspace_id)')

    terminal_window_current_workspace_id=$(echo $terminal_window | jq -r '.workspace_id')

    [[ "$terminal_window_current_workspace_id" == "$terminal_workspace_id" ]]
    terminal_window_in_terminal_workspace=$?



    # is_terminal_window_in_terminal_workspace() {
      # local terminal_window_current_wo echo "$terminal_window" | jq -r
    # }

    # Toggled means that the terminal window is currently floating,focused in the current workspace which is not the special workspace

    # if focused_window is terminal_window
    #   if focused_workspace is terminal_workspace
    #     ensure terminal_window is tiled and fullscreen
    #   else
    #     move to terminal_workspace
    #     set to previous focused window and workspace *(needs state)
    # else
    #   if focused_workspace is active
    #     move terminal_window to terminal_workspace
    #     ensure terminal_window is tiled and fullscreen
    #   else
    #     if terminal_window is in focused_workspace
    #       move to terminal_workspace
    #       set to previous active_windows and workspaces *(needs state)
    #     else
    #       move terminal_window to terminal_workspace
    #       ensure terminal_window is centered, floating and focused
    #


    # active_monitor_width=$(echo $act)
    # active_workspace_id=$(echo $focused_workspace_info | jq -r '.id')
    # active_workspace_output=$(echo $focused_workspace_info | jq -r '.output')

    # Check if terminal with our class exists
    # terminal_exists=$(niri msg -j windows | jq -r --arg class "$WEZTERM_CLASS" '.[] | select(.app_id == $class) | .app_id' | head -1)

    # Always launch the terminal if non-existent

    # terminal_window_info=$(niri msg -j windows | jq -r --arg class "$WEZTERM_CLASS" '.[] | select(.app_id == $class)')
    # terminal_window_id=$(echo $terminal_window_info | jq -r '.id')
    # terminal_window_workspace_id=$(echo $terminal_window_info | jq -r '.workspace_id')

    # terminal_workspace_output=$(niri msg -j workspaces | jq -r --arg name "terminal" '.[] | select(.name == $name) | .output')

    # if [ "$focused_workspace_id" != $terminal_window_workspace_id ]; then
    #   # Terminal is on different workspace - bring it as floating overlay
    #   niri msg action focus-window --id $terminal_window_id
    #   niri msg action move-window-to-floating --id $terminal_window_id

    #   # Calculate overlay size (80% width, 60% height, centered)
    #   overlay_width=$((width * 80 / 100))
    #   overlay_height=$((height * 80 / 100))

    #   # Resize and position the floating terminal
    #   niri msg action set-window-width "$overlay_width"
    #   niri msg action set-window-height "$overlay_height"

    #   niri msg action move-window-to-monitor --id $terminal_window_id $focused_workspace_output
    #   niri msg action center-window --id $terminal_window_id
    # else
    #   niri msg action focus-window --id $terminal_window_id
    #   # niri msg action move-window-to-monitor --id $terminal_window_id $terminal_workspace_output
    #   niri msg action move-window-to-workspace terminal
    #   niri msg action move-window-to-tiling --id $terminal_window_id
    #   niri msg action maximize-column
    #   niri msg action focus-monitor $focused_workspace_output
    #   niri msg action focus-workspace $focused_workspace_id
    # fi

  '';
in {
  home-manager.users.${vars.PRIMARY_USER.NAME} = {
    config,
    lib,
    ...
  }: {
    home.packages = [weztermToggleScript pkgs.wlrctl];

    programs.niri.settings = {
      spawn-at-startup = [
        {
          command = [
            "${pkgs.wezterm}/bin/wezterm"
            "start"
            "--class"
            weztermApplicationId
          ];
        }
      ];

      workspaces = {
        "terminal" = {
          name = weztermWorkspace;
          open-on-output = "primary";
        };
      };

      window-rules = [
        {
          matches = [
            {
              app-id = weztermApplicationId;
            }
          ];
          open-on-workspace = "terminal";
          default-column-width = {proportion = 1.0;};
        }
      ];
      binds = let
        inherit (config.lib.niri.actions) spawn;
      in {
        "Mod+X".action = spawn (lib.getExe weztermToggleScript);
      };
    };
  };
}
