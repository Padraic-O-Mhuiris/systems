local wezterm = require "wezterm"

-- local resurrect = wezterm.plugin.require(
--                       "https://github.com/MLFlexer/resurrect.wezterm")

local workspace_switcher = wezterm.plugin.require(
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
config.font_size = 12
config.freetype_load_flags = "NO_HINTING"
config.freetype_load_target = "Normal"
config.front_end = "WebGpu"

config.max_fps = 60
config.line_height = 1
config.cell_width = 1

config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false

config.color_scheme = "Ayu Dark (Gogh)"

config.window_frame = {
    font = wezterm.font_with_fallback({"Berkeley Mono"}),
    font_size = 10.0
}

config.window_padding = {left = 30, right = 30, top = 20, bottom = 10}
config.window_close_confirmation = "NeverPrompt"

config.adjust_window_size_when_changing_font_size = false

config.leader = {key = "a", mods = "CTRL", timeout_milliseconds = 1000}
config.launch_menu = {}

workspace_switcher.apply_to_config(config)
workspace_switcher.switch_workspace({
    extra_args = " | xargs -I {} sh -c '[ -d \"{}/.git\" ] && echo \"{}\"'"
})

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
    },
    {key = 's', mods = 'ALT', action = workspace_switcher.switch_workspace()}, {
        key = "Enter",
        mods = "SHIFT",
        action = wezterm.action {SendString = "\x1b\r"}
    }
}

return config
