-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix
local mcm_helper = require("reminders.mod_config_menu_helper")
local iserializer = require("reminders.iserializer")

local setup_mod_config_menu = function(mod_name, mod, on_reset_config_callback)
    local DEFAULT_TXT_COLOR = {.1, .2, .4}

    local MCM = ModConfigMenu
    assert(MCM, "Cannot Find Mod Config Menu!")

    -- clean up mod config menu
    if MCM.GetCategoryIDByName(mod_name) ~= nil then
        MCM.RemoveCategory(mod_name)
    end
    

    -- GENERAL SECTION --

    MCM.AddText(mod_name, "General", "Map Special Room Colormarks", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().map_special_colormarks_enabled
            end,

            Display = function()
                return "enabled: " .. (mod:get_config().map_special_colormarks_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().map_special_colormarks_enabled = value
            end,

            Info = {
                "Toggles whether or not to have color marks (visited, unvisited) special rooms",
                "on the minimap(REFRESH REQUIRED -> enter exit room OR quit and rejoin run / game)"
            }
        }
    )
    MCM.AddSpace(mod_name, "General")


    MCM.AddText(mod_name, "General", "Time Progress", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().time_progress_enabled
            end,

            Display = function()
                return "enabled: " .. (mod:get_config().time_progress_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().time_progress_enabled = value
            end,

            Info = {
                "Toggles the visibility of the time progress shown at the top",
                "Time progress is used to indicate boss rush / hush"
            }
        }
    )

    MCM.AddSpace(mod_name, "General")

    MCM.AddText(mod_name, "General", "Game Timer", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().game_timer_enabled
            end,

            Display = function()
                return "enabled: " .. (mod:get_config().game_timer_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().game_timer_enabled = value
            end,

            Info = {
                "Toggles the visibility of the game timer shown at the top"
            }
        }
    )
    MCM.AddSpace(mod_name, "General")

    MCM.AddText(mod_name, "General", "Lost Death Donation Notify", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().lost_death_icon_enabled
            end,

            Display = function()
                return "enabled: " .. (mod:get_config().lost_death_icon_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().lost_death_icon_enabled = value
            end,

            Info = {
                "Toggles the visibility of an icon whether or not to show you will die",
                "if donated to a blood donation machine / a devil beggar"
            }
        }
    )
    MCM.AddSpace(mod_name, "General")

    MCM.AddText(mod_name, "General", "Door Reminders", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().door_reminders_enabled
            end,

            Display = function()
                return "enabled: " .. (mod:get_config().door_reminders_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().door_reminders_enabled = value
            end,

            Info = {
                "Toggles whether or not to display door reminders in the first place",
                "For example, white fire icon above curse room in floors with white fire"
            }
        }
    )
    MCM.AddSpace(mod_name, "General")

    MCM.AddText(mod_name, "General", "Notify Info", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().notify_info_enabled
            end,

            Display = function()
                return "enabled: " .. (mod:get_config().notify_info_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().notify_info_enabled = value
            end,

            Info = {
                "Toggles whether or not notify info should be enabled",
                "Notify info shows the reminder of special rooms unvisited this floor"
            }
        }
    )
    MCM.AddSpace(mod_name, "General")

    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().notify_info_end_of_boss_notify
            end,

            Display = function()
                return "Should notify after boss complete: " .. (mod:get_config().notify_info_end_of_boss_notify and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().notify_info_end_of_boss_notify = value
            end,

            Info = {
                "Toggles whether or not notify info should auto show after",
                "A boss has been defeated"
            }
        }
    )
    MCM.AddSpace(mod_name, "General")

    MCM.AddText(mod_name, "General", "Developer", DEFAULT_TXT_COLOR)

    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().debug_mode
            end,

            Display = function()
                return "Debug Mode: " .. (mod:get_config().debug_mode and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().debug_mode = value
            end,

            Info = { -- This can also be a function instead of a table
                "debug mode displays extra information",
                "in debug console / while using the mod"
            }
        }
    )
    MCM.AddSpace(mod_name, "General")
    MCM.AddText(mod_name, "General", "!!!! DANGEROUS AREA !!!!", {0.8, 0.1, 0.1})
    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return false
            end,

            Display = function()
                return "RESET ALL SETTINGS"
            end,

            OnChange = function(value)
                on_reset_config_callback(mod)
            end,

            Info = {
                "RESETS ALL SETTINGS, CHOOSE AT YOUR OWN RISK"
            },

            Color = {0.65, 0, 0}
        }
    )
    
    ---------------------
    -- VISUALS SECTION -- 
    ---------------------
    MCM.AddText(mod_name, "Visuals", "Icon Scale", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().icon_scale * 10
            end,

            Display = function()
                return "General Icon Scale: " .. tostring(mod:get_config().icon_scale)
            end,

            Minimum = 0, Maximum = 50,

            OnChange = function(value)
                mod:get_config().icon_scale = value / 10
            end,

            Info = { -- This can also be a function instead of a table
                "Changes the general icon scale for notify info"
            }
        }
    )
    MCM.AddSpace(mod_name, "Visuals")


    MCM.AddText(mod_name, "Visuals", "Notify Info", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().notify_info_offset[1]
            end,

            Display = function()
                return "Offset X: " .. tostring(mod:get_config().notify_info_offset[1])
            end,

            Minimum = -500, Maximum = 500,

            OnChange = function(value)
                mod:get_config().notify_info_offset[1] = value
            end,

            Info = { -- This can also be a function instead of a table
                "Changes the x offset of the map reminder info at the end of each boss",
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().notify_info_offset[2]
            end,

            Display = function()
                return "Offset Y: " .. tostring(mod:get_config().notify_info_offset[2])
            end,

            Minimum = -500, Maximum = 500,

            OnChange = function(value)
                mod:get_config().notify_info_offset[2] = value
            end,

            Info = { -- This can also be a function instead of a table
                "Changes the y offset of the map reminder info at the end of each boss",
            }
        }
    )

    MCM.AddSpace(mod_name, "Visuals")

    MCM.AddText(mod_name, "Visuals", "Unvisited Rooms", DEFAULT_TXT_COLOR)
    mcm_helper.add_color_setting(
        mod_name, "Visuals", {
            CurrentSetting = function()
                return iserializer.decode_color(mod:get_config().special_color_unvisited)
            end,

            OnChange = function(new_color)
                mod:get_config().special_color_unvisited = iserializer.encode_color(new_color)
            end
        }
    )
    MCM.AddSpace(mod_name, "Visuals")

    MCM.AddText(mod_name, "Visuals", "Visited Rooms", DEFAULT_TXT_COLOR)
    mcm_helper.add_color_setting(
        mod_name, "Visuals", {
            CurrentSetting = function()
                return iserializer.decode_color(mod:get_config().special_color_visited)
            end,

            OnChange = function(new_color)
                mod:get_config().special_color_visited = iserializer.encode_color(new_color)
            end
        }
    )
    MCM.AddSpace(mod_name, "Visuals")

    MCM.AddText(mod_name, "Visuals", "Time Progress", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().time_progress_opacity * 10
            end,

            Display = function()
                return string.format("General Opacity: %.2f", mod:get_config().time_progress_opacity)
            end,

            Minimum = 0, Maximum = 1 * 10,

            OnChange = function(value)
                mod:get_config().time_progress_opacity = value / 10
            end,

            Info = {
                "Changes the overall opacity of the time progress shown at the top"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().time_progress_opacity_node * 10
            end,

            Display = function()
                return string.format("Node Opacity: %.2f", mod:get_config().time_progress_opacity_node)
            end,

            Minimum = 0, Maximum = 1 * 10,

            OnChange = function(value)
                mod:get_config().time_progress_opacity_node = value / 10
            end,

            Info = {
                "Changes the node's opacity of the time progress shown at the top",
                "This opacity will be mixed with general opacity as well."
            }
        }
    )

    mcm_helper.add_vector_setting(mod_name, "Visuals", {
        CurrentSetting = function()
            return iserializer.decode_vector(mod:get_config().time_progress_offset)
        end,

        OnChange = function(value)
            mod:get_config().time_progress_offset = iserializer.encode_vector(value)
        end
    })

    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().time_progress_width_percent * 100
            end,

            Display = function()
                return string.format("Width Percent: %.2f", mod:get_config().time_progress_width_percent)
            end,

            Minimum = 0, Maximum = 1 * 100,

            OnChange = function(value)
                mod:get_config().time_progress_width_percent = value / 100
            end,

            Info = {
                "Changes how much percent the width of the time progress",
                "should occupy compared to the screen width"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().time_progress_boss_rush_icon_enabled
            end,

            Display = function()
                return "Boss Rush Icon: " .. (mod:get_config().time_progress_boss_rush_icon_enabled and "show" or "hide")
            end,

            OnChange = function(value)
                mod:get_config().time_progress_boss_rush_icon_enabled = value
            end,

            Info = {
                "Shows or hides the boss rush icon in the time progress",
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().time_progress_hush_icon_enabled
            end,

            Display = function()
                return "Hush Icon: " .. (mod:get_config().time_progress_hush_icon_enabled and "show" or "hide")
            end,

            OnChange = function(value)
                mod:get_config().time_progress_hush_icon_enabled = value
            end,

            Info = {
                "Shows or hides the hush icon in the time progress",
            }
        }
    )
    MCM.AddSpace(mod_name, "Visuals")
end

return setup_mod_config_menu
