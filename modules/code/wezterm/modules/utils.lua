local wezterm = require("wezterm")

local M = {}

M.deep_merge = function(t1, t2)
    for key, value in pairs(t2) do
        if type(value) == "table" and type(t1[key]) == "table" then
            -- If both table1 and table2 have tables at the same key, recurse
            t1[key] = M.deep_merge(t1[key], value)
        else
            -- Otherwise, overwrite or add the key-value pair
            t1[key] = value
        end
    end
    return t1
end

M.run_child_process = function(cmd)
    local process_args = {os.getenv("SHELL"), "-c", cmd}
    local success, stdout, stderr = wezterm.run_child_process(process_args)
    if not success then
        wezterm.log_error(
            "Child process '" .. cmd .. "' failed with stderr: '" .. stderr ..
                "'")
    end
    return stdout
end

return M
