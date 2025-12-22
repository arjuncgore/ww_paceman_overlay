local M = {}

M.setup = function(cfg, _)
    -- ==== CONFIG ====
    local hours = 12
    local hoursBetween = 1

    -- local look = {
    --     X = 300,
    --     Y = 1000,
    --     color = '#000000',
    --     bold = true,
    --     size = 3
    -- }
    --
    -- local info = {
    --     { tag = "Nethers",           enabled = true,  key = "nether" },
    --     { tag = "Bastions",          enabled = true,  key = "bastion" },
    --     { tag = "Fortresses",        enabled = true,  key = "fortress" },
    --     { tag = "First Structures",  enabled = false, key = "first_structure" },
    --     { tag = "Second Structures", enabled = false, key = "second_structure" },
    --     { tag = "First Portals",     enabled = false, key = "first_portal" },
    --     { tag = "Strongholds",       enabled = false, key = "stronghold" },
    --     { tag = "End Enters",        enabled = false, key = "end" },
    --     { tag = "Completions",       enabled = false, key = "finish" },
    -- }
    --
    -- ==== CFG ====
    local username = cfg.username
    local look = cfg.look
    local info = cfg.info


    -- ==== IMPORTS ====
    local waywall = require("waywall")
    local requests = require("ww_requests.init")


    -- ==== INITIALIZING VARS ====
    local layout = ""
    local data = nil
    local text_handle = nil
    local text_handle_bold = nil

    local endpoint = "https://paceman.gg/stats/api/getSessionStats/" ..
        "?name=" .. username ..
        "&hoursBetween=" .. hoursBetween ..
        "&hours=" .. hours


    -- ==== FUNCTIONS ====
    local show_overlay = function()
        print("updating...")
        if text_handle then
            text_handle:close()
            text_handle = nil
        end

        if text_handle_bold then
            text_handle_bold:close()
            text_handle_bold = nil
        end

        layout = ""

        if data then
            if data.error then
                layout = data.error
            else
                for _, value in ipairs(info) do
                    if value.enabled == true then
                        layout = layout .. value.tag .. ":" ..
                            data[value.key].count ..
                            " (" .. data[value.key].avg .. ")\n"
                    end
                end
            end
        else
            layout = "No data"
        end

        local state = waywall.state()
        if state and state.screen ~= "inworld" then
            text_handle = waywall.text(layout, { x = look.X, y = look.Y, color = look.color, size = look.size })
            if look.bold then
                text_handle_bold = waywall.text(layout,
                    { x = look.X + 1, y = look.Y, color = look.color, size = look.size })
            end
        end
    end

    local update_overlay = function()
        requests.trigger_http_send(endpoint, "paceman")
        data = requests.receive_data("paceman")

        show_overlay()
    end

    local disable_overlay = function()
        if text_handle then
            text_handle:close(); text_handle = nil
        end
        if text_handle_bold then
            text_handle_bold:close(); text_handle_bold = nil
        end
        layout = ""
    end


    waywall.listen("state", function()
        local state = waywall.state()

        if state.screen == "wall" then
            update_overlay()
        else
            disable_overlay()
        end
    end)
end

return M
