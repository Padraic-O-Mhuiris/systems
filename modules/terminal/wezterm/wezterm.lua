local wezterm = require "wezterm"

-- local resurrect = wezterm.plugin.require(
--                       "https://github.com/MLFlexer/resurrect.wezterm")

local workspace = wezterm.plugin.require(
                      "https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

-- -- This should be better contextualised
-- package.path = package.path ..
--                    ";/home/padraic/code/nix/padraic.nix/home/terminal/wezterm/modules/?.lua"

--- https://github.com/wez/wezterm/pull/5576

local config = wezterm.config_builder()

if os.getenv("WEZTERM_CLASS") then
    config.window_class = os.getenv("WEZTERM_CLASS")
end

config.font = wezterm.font_with_fallback({"Berkeley Mono"})
config.font_size = 18
config.freetype_load_flags = "NO_HINTING"
config.freetype_load_target = "Normal"
config.front_end = "WebGpu"

config.max_fps = 144
config.line_height = 1
config.cell_width = 1

config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false

config.color_scheme = "Ayu Dark (Gogh)"

config.window_frame = {
    font = wezterm.font_with_fallback({"Berkeley Mono"}),
    font_size = 12.0
}

config.window_padding = {left = 30, right = 30, top = 20, bottom = 10}
config.window_close_confirmation = "NeverPrompt"

config.leader = {key = "a", mods = "CTRL", timeout_milliseconds = 1000}
config.launch_menu = {}

workspace.apply_to_config(config)

config.default_workspace = "~"

config.keys = {
    {
        key = "{",
        mods = "CTRL|SHIFT",
        action = wezterm.action.ActivateTabRelative(-1)
    }, {
        key = "}",
        mods = "CTRL|SHIFT",
        action = wezterm.action.ActivateTabRelative(1)
    }, {
        key = '|',
        mods = 'LEADER|SHIFT',
        action = wezterm.action.SplitHorizontal {domain = 'CurrentPaneDomain'}
    }, {
        key = '-',
        mods = 'LEADER',
        action = wezterm.action.SplitVertical {domain = 'CurrentPaneDomain'}
    }, --- Workspace
    {key = 's', mods = 'ALT', action = workspace.switch_workspace()}
    --- Ressurect
    -- {
    --     key = "w",
    --     mods = "ALT",
    --     action = wezterm.action_callback(function(win, pane)
    --         resurrect.save_state(resurrect.workspace_state.get_workspace_state())
    --     end)
    -- },
    -- {
    --     key = "W",
    --     mods = "ALT",
    --     action = resurrect.window_state.save_window_action()
    -- },
    -- {key = "T", mods = "ALT", action = resurrect.tab_state.save_tab_action()}, {
    --     key = "x",
    --     mods = "ALT",
    --     action = wezterm.action_callback(function(win, pane)
    --         resurrect.save_state(resurrect.workspace_state.get_workspace_state())
    --         resurrect.window_state.save_window_action()
    --     end)
    -- }
}

-- loads the state whenever I create a new workspace
-- wezterm.on("smart_workspace_switcher.workspace_switcher.created",
--            function(window, path, label)
--     local workspace_state = resurrect.workspace_state

--     workspace_state.restore_workspace(resurrect.load_state(label, "workspace"),
--                                       {
--         window = window,
--         relative = true,
--         restore_text = true,
--         on_pane_restore = resurrect.tab_state.default_on_pane_restore
--     })
-- end)

-- Saves the state whenever I select a workspace
-- wezterm.on("smart_workspace_switcher.workspace_switcher.selected",
--            function(window, path, label)
--     local workspace_state = resurrect.workspace_state
--     resurrect.save_state(workspace_state.get_workspace_state())
-- end)

return config
