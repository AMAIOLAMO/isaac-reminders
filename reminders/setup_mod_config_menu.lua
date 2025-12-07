-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix
local mcm_helper = require("reminders.mod_config_menu_helper")
local iserializer = require("reminders.iserializer")
local enums = require("reminders.enums")

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
                "Toggles whether or not notify info should automatically",
                "showup after a boss has been defeated"
            }
        }
    )
    MCM.AddSpace(mod_name, "General")

    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().notify_info_conditional_ultra_secret
            end,

            Display = function()
                return "Conditional Ultra Secret: " .. (mod:get_config().notify_info_conditional_ultra_secret and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().notify_info_conditional_ultra_secret = value
            end,

            Info = {
                "Toggles whether or not notify info should show Ultra Secret Rooms",
                "If and only if any player has: Red Key / Cracked Key / Soul of Cain"
            }
        }
    )
    MCM.AddSpace(mod_name, "General")
    
    MCM.AddText(mod_name, "General", "Bum kill reminders", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().bum_kill_reminders_enabled
            end,

            Display = function()
                return "enabled: " .. (mod:get_config().bum_kill_reminders_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().bum_kill_reminders_enabled = value
            end,

            Info = {
                "Toggles whether or not bum / beggars should show kill reminders",
                "For the current floor"
            }
        }
    )
    MCM.AddSpace(mod_name, "General")

    MCM.AddText(mod_name, "General", "Explosion Immunity Reminders", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().explosion_immunity_reminders_enabled
            end,

            Display = function()
                return "enabled: " .. (mod:get_config().explosion_immunity_reminders_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().explosion_immunity_reminders_enabled = value
            end,

            Info = {
                "Toggles whether to show on explosion(i.e. bombs, troll bombs) that",
                "Isaac has explosion immunity"
            }
        }
    )
    MCM.AddSpace(mod_name, "General")

    MCM.AddText(mod_name, "General", "Knife Piece Reminders", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().knife_piece_reminders_enabled
            end,

            Display = function()
                return "enabled: " .. (mod:get_config().knife_piece_reminders_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().knife_piece_reminders_enabled = value
            end,

            Info = {
                "Toggles whether to show knife piece 1 and knife piece 2 reminders",
                "at the trapdoor to the next floor"
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

            Info = {
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

            Info = {
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

            Info = {
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

            Info = {
                "Changes the y offset of the map reminder info at the end of each boss",
            }
        }
    )

    MCM.AddSpace(mod_name, "Visuals")

    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().notify_info_text_scale * 10
            end,

            Display = function()
                return "Text Scale: " .. tostring(mod:get_config().notify_info_text_scale)
            end,

            Minimum = 0, Maximum = 100,

            OnChange = function(value)
                mod:get_config().notify_info_text_scale = value / 10
            end,

            Info = {
                "changes the text scale of the notify info",
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().notify_info_line_height
            end,

            Display = function()
                return "Line Height: " .. tostring(mod:get_config().notify_info_line_height)
            end,

            Minimum = 0, Maximum = 500,

            OnChange = function(value)
                mod:get_config().notify_info_line_height = value
            end,

            Info = {
                "changes the line height of the notify info",
            }
        }
    )

    MCM.AddSpace(mod_name, "Visuals")

    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().notify_info_type
            end,

            Display = function()
                return "Notify type: " .. enums.NotifyInfoType:to_description(mod:get_config().notify_info_type)
            end,

            Minimum = enums.NotifyInfoType.NOTIFY_BEGIN,
            Maximum = enums.NotifyInfoType.NOTIFY_END,

            OnChange = function(value)
                mod:get_config().notify_info_type = value
            end,

            Info = {
                "Changes whether or not room icons / text should be shown",
            }
        }
    )
    MCM.AddText(mod_name, "Visuals", "Note: Notify Icon Only is incomplete", {0.4, 0.4, 0.4})
    MCM.AddSpace(mod_name, "Visuals")

    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().notify_info_opacity * 10
            end,

            Display = function()
                return "Opacity: " .. tostring(mod:get_config().notify_info_opacity)
            end,

            Minimum = 0, Maximum = 100,

            OnChange = function(value)
                mod:get_config().notify_info_opacity = value / 10
            end,

            Info = {
                "changes the opacity (how NOT transparent the text is) of the notify info",
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

    MCM.AddText(mod_name, "Visuals", "Explosion Immunity Reminders", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().explosion_immunity_reminder_opacity * 10
            end,

            Display = function()
                return "Opacity: " .. tostring(mod:get_config().explosion_immunity_reminder_opacity)
            end,

            Minimum = 0, Maximum = 100,

            OnChange = function(value)
                mod:get_config().explosion_immunity_reminder_opacity = value / 10
            end,

            Info = {
                "changes the opacity (how NOT transparent the reminder is)",
                "of the explosion immunity reminder"
            }
        }
    )
    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().explosion_immunity_reminder_size
            end,

            Display = function()
                return "Green Circle Size: " .. (enums.Sizes:to_description(mod:get_config().explosion_immunity_reminder_size))
            end,

            Minimum = enums.Sizes.SIZES_BEGIN, Maximum = enums.Sizes.SIZES_END,

            OnChange = function(value)
                mod:get_config().explosion_immunity_reminder_size = value
            end,

            Info = {
                "changes how large the circle around the bombs should be",
            }
        }
    )
    MCM.AddSpace(mod_name, "Visuals")

    MCM.AddText(mod_name, "Visuals", "Game Timer", DEFAULT_TXT_COLOR)
    mcm_helper.add_float_setting(
        mod_name, "Visuals", {
            Precision = 2,

            CurrentSetting = function()
                return mod:get_config().game_timer_scale
            end,

            Display = function()
                return "Scale: " .. tostring(mod:get_config().game_timer_scale)
            end,

            OnChange = function(value)
                mod:get_config().game_timer_scale = value
            end,

            Info = {
                "Changes the scale of the game timer shown above"
            }
        }
    )
    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().game_timer_opacity * 10
            end,

            Display = function()
                return "Opacity: " .. tostring(mod:get_config().game_timer_opacity)
            end,

            Minimum = 0, Maximum = 100,

            OnChange = function(value)
                mod:get_config().game_timer_opacity = value / 10
            end,

            Info = {
                "Changes the opacity (how NOT transparent it is) of the game timer"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Visuals", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().game_timer_subseconds_enabled
            end,

            Display = function()
                return "Enable Subseconds: " .. (mod:get_config().game_timer_subseconds_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().game_timer_subseconds_enabled = value
            end,

            Info = {
                "Toggles whether or not to have a more accurate timing beside seconds",
                "Examples => ON: 59:59:59.99, OFF: 59:59:59"
            }
        }
    )
end

return setup_mod_config_menu
