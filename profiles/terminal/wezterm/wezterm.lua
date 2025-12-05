local wezterm = require("wezterm")

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

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
config.font_size = 11
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
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Disable audible bell
config.audible_bell = "Disabled"

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

modules.keys.apply_to_config(config, workspace_switcher)

tabline.setup({
	options = {
		icons_enabled = true,
		theme = "Catppuccin Mocha",
		tabs_enabled = true,
		theme_overrides = {},
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tabline_a = { "mode" },
		tabline_b = { "workspace" },
		tabline_c = { " " },
		tab_active = {
			"index",
			{ "parent", padding = 0 },
			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
			"|",
			"process",
			{
				"zoomed",
				padding = 0,
			},
		},
		tab_inactive = { { "index", padding = 0 } },
		tabline_x = { "ram", "cpu" },
		tabline_y = { "datetime", "battery" },
		tabline_z = { "domain" },
	},
	extensions = {
		"smart_workspace_switcher",
		"resurrect",
	},
})
tabline.apply_to_config(config)

resurrect.state_manager.periodic_save({
	interval_seconds = 15 * 60,
	save_workspaces = true,
	save_windows = true,
	save_tabs = true,
})

wezterm.on("resurrect.error", function(err)
	wezterm.log_error("ERROR!")
	wezterm.gui.gui_windows()[1]:toast_notification("resurrect", err, nil, 3000)
end)

-- TODO
-- resurrect.state_manager.set_encryption({
-- 	enable = false,
-- 	private_key = wezterm.home_dir .. "/.age/resurrect.txt",
-- 	public_key = "age1ddyj7qftw3z5ty84gyns25m0yc92e2amm3xur3udwh2262pa5afqe3elg7",
-- })
local colors = modules.colors

-- wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

workspace_switcher.apply_to_config(config)

workspace_switcher.workspace_formatter = function(label)
	return wezterm.format({
		{ Attribute = { Italic = true } },
		{ Foreground = { Color = colors.colors.ansi[3] } },
		{ Background = { Color = colors.colors.background } },
		{ Text = "󱂬 : " .. label },
	})
end

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
	window:gui_window():set_right_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { Color = colors.colors.ansi[5] } },
		{ Text = basename(path) .. "  " },
	}))
	local workspace_state = resurrect.workspace_state

	workspace_state.restore_workspace(resurrect.state_manager.load_state(label, "workspace"), {
		window = window,
		relative = true,
		restore_text = true,

		resize_window = false,
		on_pane_restore = resurrect.tab_state.default_on_pane_restore,
	})
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(window, path, label)
	wezterm.log_info(window)
	window:gui_window():set_right_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { Color = colors.colors.ansi[5] } },
		{ Text = basename(path) .. "  " },
	}))
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
	wezterm.log_info(window)
	local workspace_state = resurrect.workspace_state
	resurrect.state_manager.save_state(workspace_state.get_workspace_state())
	resurrect.state_manager.write_current_state(label, "workspace")
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.start", function(window, _)
	wezterm.log_info(window)
end)
wezterm.on("smart_workspace_switcher.workspace_switcher.canceled", function(window, _)
	wezterm.log_info(window)
end)

return config
