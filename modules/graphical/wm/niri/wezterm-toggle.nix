{
  vars,
  pkgs,
  ...
}: let
  weztermToggleClass = "wezterm-toggle-terminal";
  weztermToggleScript = pkgs.writeShellScriptBin "weztermToggle" ''
    WEZTERM_CLASS="${weztermToggleClass}"
    set -x

    focused_workspace_info=$(niri msg -j workspaces | jq -r '.[] | select(.is_focused == true)')
    focused_workspace_id=$(echo $focused_workspace_info | jq -r '.id')
    focused_workspace_output=$(echo $focused_workspace_info | jq -r '.output')

    focused_output_info=$(niri msg -j outputs | jq -r --arg output "$focused_workspace_output" '.[] | select(.name == $output) | .logical')

    width=$(echo $focused_output_info | jq -r ".width")
    height=$(echo $focused_output_info | jq -r ".height")

    # Check if terminal with our class exists
    terminal_exists=$(niri msg -j windows | jq -r --arg class "$WEZTERM_CLASS" '.[] | select(.app_id == $class) | .app_id' | head -1)

    # Always launch the terminal if non-existent
    if [ -z "$terminal_exists" ]; then
      # Terminal doesn't exist, spawn it
      ${pkgs.wezterm}/bin/wezterm start --class "$WEZTERM_CLASS" &
      sleep 0.5  # Give it a moment to spawn
    fi

    terminal_window_info=$(niri msg -j windows | jq -r --arg class "$WEZTERM_CLASS" '.[] | select(.app_id == $class)')
    terminal_window_id=$(echo $terminal_window_info | jq -r '.id')
    terminal_window_workspace_id=$(echo $terminal_window_info | jq -r '.workspace_id')

    terminal_workspace_output=$(niri msg -j workspaces | jq -r --arg name "terminal" '.[] | select(.name == $name) | .output')

    if [ "$focused_workspace_id" != $terminal_window_workspace_id ]; then
      # Terminal is on different workspace - bring it as floating overlay
      niri msg action focus-window --id $terminal_window_id
      niri msg action move-window-to-floating --id $terminal_window_id

      # Calculate overlay size (80% width, 60% height, centered)
      overlay_width=$((width * 80 / 100))
      overlay_height=$((height * 60 / 100))

      # Resize and position the floating terminal
      niri msg action set-window-width "$overlay_width"
      niri msg action set-window-height "$overlay_height"

      niri msg action move-window-to-monitor --id $terminal_window_id $focused_workspace_output
      niri msg action center-window --id $terminal_window_id
    else
      niri msg action focus-window --id $terminal_window_id
      # niri msg action move-window-to-monitor --id $terminal_window_id $terminal_workspace_output
      niri msg action move-window-to-workspace terminal
      niri msg action move-window-to-tiling --id $terminal_window_id
      niri msg action maximize-column
      niri msg action focus-monitor $focused_workspace_output
      niri msg action focus-workspace $focused_workspace_id
    fi

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
            weztermToggleClass
          ];
        }
      ];

      workspaces = {
        "terminal" = {
          name = "terminal";
          open-on-output = "primary";
        };
      };

      window-rules = [
        {
          matches = [
            {
              app-id = weztermToggleClass;
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
