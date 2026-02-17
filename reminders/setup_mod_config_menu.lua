-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix
local mcm_helper  = include("reminders.mod_config_menu_helper")
local iserializer = include("reminders.iserializer")
local enums       = include("reminders.enums")
local langs       = include("reminders.languages")

local LE = include("reminders.language_enum")

local MCM = ModConfigMenu

local DEFAULT_TXT_COLOR = {.1, .2, .4}

local function setup_general(mod_name, mod, on_reset_config_callback)
    assert(MCM, "Cannot Find Mod Config Menu!")

    MCM.AddSpace(mod_name, "General")
    local lang_ids = langs.lang_ids

    MCM.AddSetting(
        mod_name, "General", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().language_id
            end,

            Display = function()
                return "Language: " .. langs.lang_id_to_language[mod:get_config().language_id]:get(LE.LLANG_NATIVE_NAME)
            end,

            Minimum = lang_ids.BEGIN, Maximum = lang_ids.END,

            OnChange = function(value)
                mod:get_config().language_id = value
            end,

            Info = {
                "The language you wish to use",
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
end

local function setup_doors(mod_name, mod)
    MCM.AddText(mod_name, "Doors", "Door Reminders", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Doors", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().door_reminders_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().door_reminders_enabled and "on" or "off")
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
end

local function setup_map(mod_name, mod)
    MCM.AddText(mod_name, "Map", "Map Special Room Colormarks", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Map", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().map_special_colormarks_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().map_special_colormarks_enabled and "on" or "off")
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
    MCM.AddSpace(mod_name, "Map")

    MCM.AddText(mod_name, "Map", "Unvisited Rooms", DEFAULT_TXT_COLOR)
    mcm_helper.add_color_setting(
        mod_name, "Map", {
            CurrentSetting = function()
                return iserializer.decode_color(mod:get_config().special_color_unvisited)
            end,

            OnChange = function(new_color)
                mod:get_config().special_color_unvisited = iserializer.encode_color(new_color)
            end
        }
    )
    MCM.AddSpace(mod_name, "Map")

    MCM.AddText(mod_name, "Map", "Visited Rooms", DEFAULT_TXT_COLOR)
    mcm_helper.add_color_setting(
        mod_name, "Map", {
            CurrentSetting = function()
                return iserializer.decode_color(mod:get_config().special_color_visited)
            end,

            OnChange = function(new_color)
                mod:get_config().special_color_visited = iserializer.encode_color(new_color)
            end
        }
    )
    MCM.AddSpace(mod_name, "Map")

end

local function setup_items(mod_name, mod)
    MCM.AddText(mod_name, "Items", "Schoolbag Reminder", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Items", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().schoolbag_reminder_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().schoolbag_reminder_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().schoolbag_reminder_enabled = value
            end,

            Info = {
                "Enables or disables schoolbag reminder"
            },
        }
    )

    MCM.AddSetting(
        mod_name, "Items", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().schoolbag_reminder_yoffset
            end,

            Display = function()
                return "Y offset: " .. mod:get_config().schoolbag_reminder_yoffset
            end,

            Minimum = -500,
            Maximum = 500,

            OnChange = function(value)
                mod:get_config().schoolbag_reminder_yoffset = value
            end,

            Info = {
                "The vertical offset (y offset) of where the schoolbag should appear relative",
                "to isaac themselves"
            }
        }
    )
    
    MCM.AddSpace(mod_name, "Items")

    MCM.AddText(mod_name, "Items", "Knife Piece Reminders", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Items", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().knife_piece_reminders_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().knife_piece_reminders_enabled and "on" or "off")
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
    MCM.AddSpace(mod_name, "Items")

    MCM.AddText(mod_name, "Items", "Explosion Immunity Reminders", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Items", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().explosion_immunity_reminders_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().explosion_immunity_reminders_enabled and "on" or "off")
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
    MCM.AddSpace(mod_name, "Items")

    MCM.AddSetting(
        mod_name, "Items", {
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
        mod_name, "Items", {
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
    MCM.AddSpace(mod_name, "Items")
end

local function setup_extra_info(mod_name, mod)
    MCM.AddText(mod_name, "Extra Info", "Notify Info Popup", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Extra Info", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().notify_info_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().notify_info_enabled and "on" or "off")
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

    MCM.AddSetting(
        mod_name, "Extra Info", {
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

    MCM.AddSetting(
        mod_name, "Extra Info", {
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

    MCM.AddSetting(
        mod_name, "Extra Info", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().notify_info_should_bypass_guaranteed_rooms
            end,

            Display = function()
                return "Guaranteed Rooms Bypass: " ..
                    (mod:get_config().notify_info_should_bypass_guaranteed_rooms and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().notify_info_should_bypass_guaranteed_rooms = value
            end,

            Info = {
                "Toggles whether or not notify info should bypass certain guaranteed",
                "rooms for the floor(Treasure rooms, secret rooms, super secret rooms, etc.)"
            }
        }
    )

        -- notify_info_should_bypass_guaranteed_rooms = true,

    MCM.AddSpace(mod_name, "Extra Info")

    MCM.AddSetting(
        mod_name, "Extra Info", {
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
    MCM.AddSpace(mod_name, "Extra Info")

    MCM.AddSetting(
        mod_name, "Extra Info", {
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
        mod_name, "Extra Info", {
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

    MCM.AddSpace(mod_name, "Extra Info")

    MCM.AddSetting(
        mod_name, "Extra Info", {
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
        mod_name, "Extra Info", {
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

    MCM.AddSpace(mod_name, "Extra Info")

    MCM.AddSetting(
        mod_name, "Extra Info", {
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
    MCM.AddText(mod_name, "Extra Info", "Note: Notify Icon Only is incomplete", {0.4, 0.4, 0.4})
    MCM.AddSpace(mod_name, "Extra Info")

    MCM.AddSetting(
        mod_name, "Extra Info", {
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
    MCM.AddSpace(mod_name, "Extra Info")
end

local function setup_time(mod_name, mod)
    MCM.AddText(mod_name, "Time", "Time Progress", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Time", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().time_progress_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().time_progress_enabled and "on" or "off")
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

    MCM.AddSetting(
        mod_name, "Time", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().time_progress_disable_in_greed
            end,

            Display = function()
                return "Disable in greed mode: " .. (mod:get_config().time_progress_disable_in_greed and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().time_progress_disable_in_greed = value
            end,

            Info = {
                "Whether or not to disable time progress in greed mode always",
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Time", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().time_progress_display_trigger
            end,

            Display = function()
                return "Display trigger: " .. enums.DisplayTrigger:to_description(
                    mod:get_config().time_progress_display_trigger
                )
            end,

            Minimum = enums.DisplayTrigger.TRIGGER_BEGIN,
            Maximum = enums.DisplayTrigger.TRIGGER_END,

            OnChange = function(value)
                mod:get_config().time_progress_display_trigger = value
            end,

            Info = {
                "Switches between different kinds of display mode:",
                "Always = Always displays",
                "On Extra Info = Displays only when holding map button"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Time", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().time_progress_invert_display_trigger
            end,

            Display = function()
                return "Invert Display Trigger: " .. (mod:get_config().time_progress_invert_display_trigger and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().time_progress_invert_display_trigger = value
            end,

            Info = {
                "Whether or not to invert the trigger for displaying the Time progress",
                "ALWAYS -> NEVER",
                "ON TRIGGER INFO(show up when you hold map) -> ON NOT TRIGGER INFO(show up when you DONT hold)"
            }
        }
    )

    MCM.AddSpace(mod_name, "Time")

    MCM.AddSetting(
        mod_name, "Time", {
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
        mod_name, "Time", {
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

    mcm_helper.add_vector_setting(mod_name, "Time", {
        CurrentSetting = function()
            return iserializer.decode_vector(mod:get_config().time_progress_offset)
        end,

        OnChange = function(value)
            mod:get_config().time_progress_offset = iserializer.encode_vector(value)
        end
    })

    MCM.AddSetting(
        mod_name, "Time", {
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
        mod_name, "Time", {
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
        mod_name, "Time", {
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
    MCM.AddSpace(mod_name, "Time")


    MCM.AddText(mod_name, "Time", "Game Timer", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Time", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().game_timer_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().game_timer_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().game_timer_enabled = value
            end,

            Info = {
                "Toggles whether to enable the game timer shown at the top"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Time", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().game_timer_display_trigger
            end,

            Display = function()
                return "Display trigger: " .. enums.DisplayTrigger:to_description(
                    mod:get_config().game_timer_display_trigger
                )
            end,

            Minimum = enums.DisplayTrigger.TRIGGER_BEGIN,
            Maximum = enums.DisplayTrigger.TRIGGER_END,

            OnChange = function(value)
                mod:get_config().game_timer_display_trigger = value
            end,

            Info = {
                "Switches between different kinds of display mode:",
                "Always = Always displays",
                "On Extra Info = Displays only when holding map button"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Time", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().game_timer_invert_display_trigger
            end,

            Display = function()
                return "Invert Display Trigger: " .. (mod:get_config().game_timer_invert_display_trigger and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().game_timer_invert_display_trigger = value
            end,

            Info = {
                "Whether or not to invert the trigger for displaying the Game Timer",
                "ALWAYS -> NEVER",
                "ON TRIGGER INFO(show up when you hold map) -> ON NOT TRIGGER INFO(show up when you DONT hold)"
            }
        }
    )
    MCM.AddSpace(mod_name, "Time")

    mcm_helper.add_vector_setting(mod_name, "Time", {
        CurrentSetting = function()
            return iserializer.decode_vector(mod:get_config().game_timer_offset)
        end,

        OnChange = function(value)
            mod:get_config().game_timer_offset = iserializer.encode_vector(value)
        end
    })

    mcm_helper.add_float_setting(
        mod_name, "Time", {
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
        mod_name, "Time", {
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
        mod_name, "Time", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().game_timer_subseconds_enabled
            end,

            Display = function()
                return "Subseconds Enabled: " .. (mod:get_config().game_timer_subseconds_enabled and "on" or "off")
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

local function setup_characters(mod_name, mod)
    MCM.AddText(mod_name, "Characters", "Lost Death Donation Notify", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Characters", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().lost_death_icon_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().lost_death_icon_enabled and "on" or "off")
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

    MCM.AddSpace(mod_name, "Characters")

    MCM.AddText(mod_name, "Characters", "Near Death Reminders", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Characters", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().near_death_effect_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().near_death_effect_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().near_death_effect_enabled = value
            end,

            Info = {
                "Toggles whether or not to display an effect when the player is",
                "on low critical health"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Characters", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().near_death_effect_hit_units_threshold
            end,

            Display = function()
                return "Hit Units Threshold: " .. mod:get_config().near_death_effect_hit_units_threshold
            end,

            Minimum = 1,
            Maximum = 20,

            OnChange = function(value)
                mod:get_config().near_death_effect_hit_units_threshold = value
            end,

            Info = {
                "Threshold for how many hits remaining for isaac to show the near death effect",
                "1 unit = half a red heart / soul heart / black heart = 1 bone heart",
                "= 1 holy mantle / holy card / wooden cross / blanket mantle",
                "This is ignored in The Lost / Tainted Lost"
            }
        }
    )

    MCM.AddSpace(mod_name, "Characters")

    MCM.AddSetting(
        mod_name, "Characters", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().near_death_effect_strength * 10
            end,

            Display = function()
                return "Effect Strength: " .. tostring(mod:get_config().near_death_effect_strength)
            end,

            Minimum = 0, Maximum = 10,

            OnChange = function(value)
                mod:get_config().near_death_effect_strength = value / 10
            end,

            Info = {
                "Changes the near death effect strength"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Characters", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().near_death_effect_opacity * 10
            end,

            Display = function()
                return "Effect Opacity: " .. tostring(mod:get_config().near_death_effect_opacity)
            end,

            Minimum = 0, Maximum = 10,

            OnChange = function(value)
                mod:get_config().near_death_effect_opacity = value / 10
            end,

            Info = {
                "Changes the opacity(aka how NOT transparent it is) of the death effect"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Characters", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().near_death_effect_shader_type
            end,

            Display = function()
                return "Shader Type: " .. enums.NearDeathEffectShader:to_description(
                    mod:get_config().near_death_effect_shader_type
                )
            end,

            Minimum = enums.NearDeathEffectShader.EFFECT_SHADER_BEGIN,
            Maximum = enums.NearDeathEffectShader.EFFECT_SHADER_END,

            OnChange = function(value)
                mod:get_config().near_death_effect_shader_type = value
            end,

            Info = {
                "Changes the near death effect type",
                "Currently there are two types: Circle and Surround"
            }
        }
    )

end

local function setup_deals(mod_name, mod)
    MCM.AddText(mod_name, "Deals", "Bum kill reminders", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Deals", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().bum_kill_reminders_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().bum_kill_reminders_enabled and "on" or "off")
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
    MCM.AddSpace(mod_name, "Deals")
end

local function setup_rooms(mod_name, mod)
    MCM.AddText(mod_name, "Rooms", "Potential Secret Room Placeholders", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Rooms", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().secret_room_placeholder_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().secret_room_placeholder_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().secret_room_placeholder_enabled = value
            end,

            Info = {
                "Toggles whether or not to show potential secret room placeholders"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Rooms", {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return mod:get_config().secret_room_placeholder_display_trigger
            end,

            Display = function()
                return "Display trigger: " .. enums.DisplayTrigger:to_description(
                    mod:get_config().secret_room_placeholder_display_trigger
                )
            end,

            Minimum = enums.DisplayTrigger.TRIGGER_BEGIN,
            Maximum = enums.DisplayTrigger.TRIGGER_END,

            OnChange = function(value)
                mod:get_config().secret_room_placeholder_display_trigger = value
            end,

            Info = {
                "Switches between different kinds of display mode:",
                "Always = Always displays",
                "On Extra Info = Displays only when holding map button"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Rooms", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().secret_room_placeholder_only_hard_to_find_enabled
            end,

            Display = function()
                return "Only hard / bigger rooms: " .. (mod:get_config().secret_room_placeholder_only_hard_to_find_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().secret_room_placeholder_only_hard_to_find_enabled = value
            end,

            Info = {
                "Toggles whether or not to only show up placeholders for harder(bigger) rooms"
            }
        }
    )

    MCM.AddSetting(
        mod_name, "Rooms", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().secret_room_placeholder_only_clear_rooms_enabled
            end,

            Display = function()
                return "Enable only when room cleared: " ..
                    (mod:get_config().secret_room_placeholder_only_clear_rooms_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().secret_room_placeholder_only_clear_rooms_enabled = value
            end,

            Info = {
                "Toggles whether or not placeholders should show up ONLY when room is cleared"
            }
        }
    )
    MCM.AddSpace(mod_name, "Rooms")
end

local function setup_unlocks(mod_name, mod)
    MCM.AddText(mod_name, "Unlocks", "Cracked Key Reminder on Dad's Note", DEFAULT_TXT_COLOR)
    MCM.AddSetting(
        mod_name, "Unlocks", {
            Type = MCM.OptionType.BOOLEAN,

            CurrentSetting = function()
                return mod:get_config().cracked_key_reminder_enabled
            end,

            Display = function()
                return "Enabled: " .. (mod:get_config().cracked_key_reminder_enabled and "on" or "off")
            end,

            OnChange = function(value)
                mod:get_config().cracked_key_reminder_enabled = value
            end,

            Info = {
                "Toggles whether or not a red key should show up on dad's note",
                "to remind you of cracked key for tainted unlocks"
            }
        }
    )
end

local setup_mod_config_menu = function(mod_name, mod, on_reset_config_callback)
    assert(MCM, "Cannot Find Mod Config Menu!")

    -- clean up mod config menu if it has been drawn before
    if MCM.GetCategoryIDByName(mod_name) ~= nil then
        MCM.RemoveCategory(mod_name)
    end
    

    -- GENERAL SECTION --
    setup_general(mod_name, mod, on_reset_config_callback)
    setup_extra_info(mod_name, mod)
    setup_doors(mod_name, mod)
    setup_map(mod_name, mod)
    setup_rooms(mod_name, mod)
    setup_items(mod_name, mod)
    setup_time(mod_name, mod)
    setup_characters(mod_name, mod)
    setup_unlocks(mod_name, mod)
    setup_deals(mod_name, mod)

    -- TODO: instead of doing it like this, (since tables are iterated randomly)
    local CREDITS = {
        ["Mod Made By"] = { "CxRedix" },
        ["Sprites"] = { "All done by me :D", "(Except in game sprites)" },
        ["Programming"] = { "All done by me" },

        ["Special Thanks"] = {
            "Mod Config Menu Pure & MiniMAPI",
            "",
            "A lot of helpful feedback from",
            "extremethreat1",
            "",
            "The original Pyromaniac Reminder",
            "-- Barney(Steam)",
            "",
            "The original Idea of Knife Piece Reminder",
            "Don't Forget Mod",
            "-- I sniff seats(Steam)",
            "",
            "Original Idea of Secret Room Placeholder",
            "Secretroom Placeholder Mod",
            "-- HeliOS(Steam)",
            "",
            "Original Idea of Near Death Reminder",
            "Critical Damage Mod",
            "-- Harvester(Steam)",

            "Translations",
            "English: CxRedix",
            "Chinese: CxRedix",
            "Russian: ExtremeThreat1",
        }
    }

    for section, lines in pairs(CREDITS) do
        mcm_helper.add_label_setting(mod_name, "Credits", section)
    
        for _, line in ipairs(lines) do
            mcm_helper.add_label_setting(mod_name, "Credits", line)
        end

        MCM.AddSpace(mod_name, "Credits")
    end
end

return setup_mod_config_menu
