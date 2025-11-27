local wezterm = require("wezterm")
-- local resurrect = wezterm.plugin.require(
-- "https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
local modules = require("modules")
-- -- This should be better contextualised
-- package.path = package.path ..
--                    ";/home/padraic/code/nix/padraic.nix/home/terminal/wezterm/modules/?.lua"
--- https://github.com/wez/wezterm/pull/5576

local config = wezterm.config_builder()

if os.getenv("WEZTERM_CLASS") then
	config.window_class = os.getenv("WEZTERM_CLASS")
end

config.font = wezterm.font_with_fallback({ "Berkeley Mono" })
config.font_size = 13
config.freetype_load_flags = "DEFAULT"
config.freetype_load_target = "Light"

config.automatically_reload_config = true

-- This is broken under WebGpu, don't enable
config.enable_wayland = false
config.front_end = "WebGpu"

config.max_fps = 120
config.line_height = 1
config.cell_width = 1

config.term = "wezterm"

-- Cursor configuration
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 250

config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.tab_and_split_indices_are_zero_based = true
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.switch_to_last_active_tab_when_closing_tab = true
config.color_scheme = "Ayu Dark (Gogh)"
config.window_padding = { left = 30, right = 30, top = 20, bottom = 10 }
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.launch_menu = {}

config.use_dead_keys = false
config.scrollback_lines = 5000
config.default_workspace = "~"

workspace_switcher.apply_to_config(config)
modules.bar.apply_to_config(config, bar)
modules.keys.apply_to_config(config, workspace_switcher)

return config
