local wezterm = require("wezterm")
local act = wezterm.action
local M = {}

-- Resize pane configuration
local RESIZE_AMOUNT = 5
local RESIZE_TIMEOUT = 2000

-- Helper to create resize action with logging
local function resize_action(direction, amount)
	return wezterm.action_callback(function(window, pane)
		wezterm.log_info("resize_pane: " .. direction .. " pressed")
		window:perform_action(act.AdjustPaneSize({ direction, amount }), pane)
	end)
end

-- Helper to activate resize mode
local function activate_resize_mode(direction, amount)
	return wezterm.action_callback(function(window, pane)
		wezterm.log_info("Activating resize_pane mode")
		window:perform_action(
			act.Multiple({
				act.AdjustPaneSize({ direction, amount }),
				act.ActivateKeyTable({
					name = "resize_pane",
					one_shot = false,
					timeout_milliseconds = RESIZE_TIMEOUT,
				}),
			}),
			pane
		)
	end)
end

M.apply_to_config = function(config, workspace_switcher)
	config.disable_default_key_bindings = true
	config.disable_default_mouse_bindings = false
	config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
	config.key_tables = {
		copy_mode = {
			{ key = "Tab", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
			{ key = "Tab", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
			{ key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
			{ key = "Escape", mods = "NONE", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
			{ key = "Space", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
			{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
			{ key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
			{ key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
			{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
			{ key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
			{ key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
			{ key = "F", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
			{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
			{ key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
			{ key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
			{ key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
			{ key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
			{ key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
			{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
			{ key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
			{ key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
			{ key = "O", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
			{ key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
			{ key = "T", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
			{ key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
			{ key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
			{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
			{ key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
			{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
			{ key = "b", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
			{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
			{ key = "c", mods = "CTRL", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
			{ key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
			{ key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
			{ key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
			{ key = "f", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
			{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
			{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
			{ key = "g", mods = "CTRL", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
			{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
			{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
			{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
			{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
			{ key = "m", mods = "ALT", action = act.CopyMode("MoveToStartOfLineContent") },
			{ key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
			{ key = "q", mods = "NONE", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
			{ key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
			{ key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
			{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
			{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
			{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
			{
				key = "y",
				mods = "NONE",
				action = act.Multiple({
					{ CopyTo = "ClipboardAndPrimarySelection" },
					{ Multiple = { "ScrollToBottom", { CopyMode = "Close" } } },
				}),
			},
			{ key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
			{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
			{ key = "End", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
			{ key = "Home", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
			{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
			{ key = "LeftArrow", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
			{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
			{ key = "RightArrow", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
			{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
			{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
		},

		search_mode = {
			{ key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
			{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
			{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
			{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
			{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
			{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
			{ key = "PageUp", mods = "NONE", action = act.CopyMode("PriorMatchPage") },
			{ key = "PageDown", mods = "NONE", action = act.CopyMode("NextMatchPage") },
			{ key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
			{ key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
		},

		resize_pane = {
			{ key = "h", mods = "NONE", action = resize_action("Left", RESIZE_AMOUNT) },
			{ key = "j", mods = "NONE", action = resize_action("Down", RESIZE_AMOUNT) },
			{ key = "k", mods = "NONE", action = resize_action("Up", RESIZE_AMOUNT) },
			{ key = "l", mods = "NONE", action = resize_action("Right", RESIZE_AMOUNT) },
			{ key = "H", mods = "SHIFT", action = resize_action("Left", RESIZE_AMOUNT) },
			{ key = "J", mods = "SHIFT", action = resize_action("Down", RESIZE_AMOUNT) },
			{ key = "K", mods = "SHIFT", action = resize_action("Up", RESIZE_AMOUNT) },
			{ key = "L", mods = "SHIFT", action = resize_action("Right", RESIZE_AMOUNT) },
			{
				key = "Escape",
				mods = "NONE",
				action = wezterm.action_callback(function(window, pane)
					wezterm.log_info("resize_pane: Escape pressed - exiting mode")
					window:perform_action("PopKeyTable", pane)
				end),
			},
		},
	}

	config.keys = {
		-- ============================================================================
		-- DEFAULT KEY BINDINGS (WezTerm standard bindings, organized by function)
		-- ============================================================================

		-- Tab Navigation
		{ key = "{", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
		{ key = "H", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
		{ key = "}", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(1) },
		{ key = "L", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(1) },

		-- Tab Management
		{ key = "T", mods = "SHIFT|CTRL", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "W", mods = "SHIFT|CTRL", action = act.CloseCurrentTab({ confirm = true }) },
		{ key = "{", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
		{ key = "H", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
		{ key = "}", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },
		{ key = "L", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },

		-- { key = "(", mods = "SHIFT|CTRL", action = act.ActivateTab(-1) },
		-- { key = ")", mods = "SHIFT|CTRL", action = act.ActivateTab(1) },

		-- Font Size
		{ key = "+", mods = "SHIFT|CTRL", action = act.IncreaseFontSize },
		{ key = "_", mods = "SHIFT|CTRL", action = act.DecreaseFontSize },
		{ key = "0", mods = "CTRL", action = act.ResetFontSize },

		-- Pane Splitting
		{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "|", mods = "SHIFT|LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

		-- Pane Navigation
		{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
		{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
		{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
		{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },

		-- Pane Resize Mode
		{ key = "H", mods = "LEADER|SHIFT", action = activate_resize_mode("Left", RESIZE_AMOUNT) },
		{ key = "J", mods = "LEADER|SHIFT", action = activate_resize_mode("Down", RESIZE_AMOUNT) },
		{ key = "K", mods = "LEADER|SHIFT", action = activate_resize_mode("Up", RESIZE_AMOUNT) },
		{ key = "L", mods = "LEADER|SHIFT", action = activate_resize_mode("Right", RESIZE_AMOUNT) },

		-- Pane Zoom
		{ key = "Z", mods = "SHIFT|CTRL", action = act.TogglePaneZoomState },
		{
			key = "s",
			mods = "LEADER",
			action = act.PaneSelect({
				show_pane_ids = true,
				-- alphabet = "1234567890",
			}),
		},

		-- Copy & Paste
		{ key = "C", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
		{ key = "V", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

		{ key = "Copy", mods = "NONE", action = act.CopyTo("Clipboard") },
		{ key = "Paste", mods = "NONE", action = act.PasteFrom("Clipboard") },

		-- Copy Mode
		{ key = "X", mods = "SHIFT|CTRL", action = act.ActivateCopyMode },

		-- Character Select
		{
			key = "U",
			mods = "SHIFT|CTRL",
			action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
		},

		-- Search
		{ key = "F", mods = "SHIFT|CTRL", action = act.Search("CurrentSelectionOrEmptyString") },

		-- Scrollback
		{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
		{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
		{ key = "J", mods = "SHIFT|ALT", action = act.ScrollByLine(1) },
		{ key = "K", mods = "SHIFT|ALT", action = act.ScrollByLine(-1) },
		-- Doesn't seem to work
		-- { key = "DownArrow", mods = "SHIFT|ALT", action = act.ScrollToPrompt(1) },
		-- { key = "UpArrow", mods = "SHIFT|ALT", action = act.ScrollToPrompt(-1) },

		-- Window Management
		{ key = "Enter", mods = "ALT", action = act.ToggleFullScreen },

		-- System & Configuration
		{ key = "P", mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
		-- { key = "L", mods = "CTRL", action = act.ShowDebugOverlay },
		-- { key = "L", mods = "SHIFT|CTRL", action = act.ShowDebugOverlay },
		-- { key = "l", mods = "SHIFT|CTRL", action = act.ShowDebugOverlay },
		{ key = "R", mods = "SHIFT|CTRL", action = act.ReloadConfiguration },

		-- Quick Select
		{ key = "phys:Space", mods = "SHIFT|CTRL", action = act.QuickSelect },

		-- Special Keys
		{ key = "Enter", mods = "SHIFT", action = act.SendString("\u{1b}\r") },

		-- ============================================================================
		-- CUSTOM KEY BINDINGS (Non-default, project-specific bindings)
		-- ============================================================================

		-- Workspace Management
		{ key = "s", mods = "ALT", action = workspace_switcher.switch_workspace() },
	}
end

return M
