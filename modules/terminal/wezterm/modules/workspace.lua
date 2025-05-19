local wezterm = require("wezterm")
local utils = require("utils")

local act = wezterm.action
local mux = wezterm.mux

local pub = {zoxide_path = "zoxide", choices = {}}

local workspace_formatter = function(label)
    return wezterm.format({{Text = "󱂬 : " .. label}})
end

local current_mux_window = function(workspace)
    for _, mux_win in ipairs(mux.all_windows()) do
        if mux_win:get_workspace() == workspace then return mux_win end
    end
    error("Could not find a workspace with the name: " .. workspace)
end

local workspace_elements = function(workspaces_table)
    local workspace_ids = {}
    for _, workspace in ipairs(mux.get_workspace_names()) do
        table.insert(workspaces_table,
                     {id = workspace, label = workspace_formatter(workspace)})
        workspace_ids[workspace] = true
    end
    return workspaces_table, workspace_ids
end

local zoxide_elements = function(workspaces_table, opts)
    if opts == nil then opts = {extra_args = "", workspace_ids = {}} end

    local stdout = utils.run_child_process(
                       pub.zoxide_path .. " query -l " ..
                           (opts.extra_args or ""))

    for _, path in ipairs(wezterm.split_by_newlines(stdout)) do
        local updated_path = string.gsub(path, wezterm.home_dir, "~")
        if not opts.workspace_ids[updated_path] then
            table.insert(workspaces_table, {id = path, label = updated_path})
        end
    end
    return workspaces_table
end

local project_elements = function(workspaces_table)
    local file = io.open("$HOME/.projects", "r")
    if not file then error("Could not open the file") end
    for path in file:lines() do
        local updated_path = string.gsub(path, wezterm.home_dir, "~")
        table.insert(workspaces_table, {id = path, label = updated_path})
    end
    file:close()
    return workspaces_table
end

local workspace_list = function(opts)
    if opts == nil then opts = {extra_args = ""} end

    local workspaces = {}
    workspaces, opts.workspace_ids = workspace_elements(workspaces)
    -- workspaces = project_elements(workspaces)
    workspaces = zoxide_elements(workspaces, opts)
    return workspaces
end

local workspace_exists = function(workspace)
    for _, workspace_name in ipairs(mux.get_workspace_names()) do
        if workspace == workspace_name then return true end
    end
    return false
end

local workspace_chosen = function(window, pane, workspace, label_workspace)
    window:perform_action(act.SwitchToWorkspace({name = workspace}), pane)

    wezterm.emit("smart_workspace_switcher.workspace_switcher.chosen",
                 current_mux_window(workspace), workspace, label_workspace)
end

local zoxide_chosen = function(window, pane, path, label_path)
    window:perform_action(act.SwitchToWorkspace({
        name = label_path,
        spawn = {label = "Workspace: " .. label_path, cwd = path}
    }), pane)
    wezterm.emit("smart_workspace_switcher.workspace_switcher.created",
                 current_mux_window(label_path), path, label_path)
    -- increment zoxide path score
    utils.run_child_process(pub.zoxide_path .. " add " .. path)
end

local switch_workspace = function(opts)
    return wezterm.action_callback(function(window, pane)
        wezterm.emit("smart_workspace_switcher.workspace_switcher.start",
                     window, pane)
        local workspaces = workspace_list(opts)
        window:perform_action(act.InputSelector({
            title = "Choose Workspace",
            description = "Select a workspace and press Enter = accept, Esc = cancel, / = filter",
            fuzzy_description = "Workspace to switch: ",
            choices = workspaces,
            fuzzy = true,
            action = wezterm.action_callback(
                function(inner_window, inner_pane, id, label)
                    if id and label then
                        wezterm.emit(
                            "smart_workspace_switcher.workspace_switcher.selected",
                            window, id, label)

                        if workspace_exists(id) then
                            workspace_chosen(inner_window, inner_pane, id, label)
                        else
                            zoxide_chosen(inner_window, inner_pane, id, label)
                        end
                    else
                        wezterm.emit(
                            "smart_workspace_switcher.workspace_switcher.canceled",
                            window, pane)
                    end
                end)
        }), pane)
    end)
end

pub.apply_to_config = function(config)
    if config then
        if not config.keys then config.keys = {} end
    else
        config = {keys = {}}
    end
    table.insert(config.keys,
                 {key = "s", mods = "ALT", action = switch_workspace()})

end

return pub
