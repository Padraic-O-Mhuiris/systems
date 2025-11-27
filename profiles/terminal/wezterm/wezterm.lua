local wezterm = require("wezterm")
-- local resurrect = wezterm.plugin.require(
-- "https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
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

config.automatically_reload_config = true

config.enable_wayland = true
config.freetype_load_flags = "NO_HINTING"
config.freetype_load_target = "Normal"

-- Front-end rendering backend
-- Options: "OpenGL", "WebGpu", "Software"
config.front_end = "OpenGL"

-- Reduce max_fps if GPU struggling (120 -> 60)
config.max_fps = 120
config.line_height = 1
config.cell_width = 1

config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.tab_and_split_indices_are_zero_based = true
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.switch_to_last_active_tab_when_closing_tab = true
config.color_scheme = "Ayu Dark (Gogh)"
config.window_padding = { left = 30, right = 30, top = 20, bottom = 10 }
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = true
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.launch_menu = {}

config.use_dead_keys = false
config.scrollback_lines = 5000

-- config.disable_default_key_bindings = false

workspace_switcher.apply_to_config(config)
config.default_workspace = "~"

config.keys = {
	{
		key = "{",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		key = "}",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{ key = "s", mods = "ALT", action = workspace_switcher.switch_workspace() },
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action({ SendString = "\x1b\r" }),
	},
}

-- The filled in variant of the < symbol
-- local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

-- -- The filled in variant of the > symbol
-- local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- local function tab_title(tab_info)
-- 	local title = tab_info.tab_title
-- 	if title and #title > 0 then
-- 		return title
-- 	end
-- 	return tab_info.active_pane.title
-- end

-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
-- 	local edge_background = "#0b0022"
-- 	local background = tab.is_active and "#2b2042" or (hover and "#3b3052" or "#1b1032")
-- 	local foreground = tab.is_active and "#c0c0c0" or (hover and "#909090" or "#808080")
-- 	local edge_foreground = background

-- 	local title = tab_title(tab)
-- 	title = wezterm.truncate_right(title, max_width - 2)

-- 	return {
-- 		{ Background = { Color = edge_background } },
-- 		{ Foreground = { Color = edge_foreground } },
-- 		{ Text = SOLID_LEFT_ARROW },
-- 		{ Background = { Color = background } },
-- 		{ Foreground = { Color = foreground } },
-- 		{ Text = title },
-- 		{ Foreground = { Color = foreground } },
-- 		{ Background = { Color = edge_background } },
-- 		{ Foreground = { Color = edge_foreground } },
-- 		{ Text = SOLID_RIGHT_ARROW },
-- 	}
-- end)

return config
