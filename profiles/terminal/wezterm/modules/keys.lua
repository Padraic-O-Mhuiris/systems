local wezterm = require("wezterm")

local M = {}

M.apply_to_config = function(config, workspace_switcher)
	config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

	config.disable_default_key_bindings = true
	-- config.disable_default_mouse_bindings = true

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
end

return M
