-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

local iserializer = require("reminders.iserializer")
local enums = require("reminders.enums")
local Configs = {}

function Configs.get_default_config()
    -- must conform to these few types:
    -- number, boolean, table / array, strings 
    return {
        debug_mode = false,

        map_special_colormarks_enabled = true,

        special_color_unvisited = iserializer.encode_color(Color(1, 0, 0)),
        special_color_visited = iserializer.encode_color(Color(0, 1, 0)),
        normal_color_marked = iserializer.encode_color(Color(1, 1, 0)),

        notify_info_enabled = true,
        -- TODO: should move all of the text headers to be simply just a constant
        notify_text_header = "=== ![Missed Special Rooms]! ===",
        notify_text_header_ok = "No Missed Special Rooms :)",
        notify_info_offset = iserializer.encode_vector(Vector(0, 0)),
        notify_info_end_of_boss_notify = true,
        notify_info_conditional_ultra_secret = true,
        notify_info_text_scale = 1.0,
        notify_info_line_height = 15,
        notify_info_type = enums.NotifyInfoType.NOTIFY_ICON_TEXT,
        notify_info_opacity = 1.0,

        icon_scale = 1.5,

        lost_death_icon_enabled = true,
        -- TODO: should specify exactly what offset they meant (Y offset here)
        lost_death_dono_offset = 44.0,
        lost_death_devil_beggar_offset = 22.0,

        door_reminders_enabled = true,

        door_reminders_yoffset = 20,

        time_progress_enabled = true,
        time_progress_offset = iserializer.encode_vector(Vector(0, 0)),
        time_progress_opacity = 0.8,
        time_progress_width_percent = 0.2,
        time_progress_opacity_node = 1.0,

        time_progress_boss_rush_icon_enabled = true,
        time_progress_hush_icon_enabled = true,
        time_progress_disable_in_greed = true,

        game_timer_enabled = true,
        game_timer_offset = iserializer.encode_vector(Vector(0, 0)),
        game_timer_subseconds_enabled = true,
        game_timer_scale = 0.8,
        game_timer_opacity = 0.9,

        bum_kill_reminders_enabled = true,

        explosion_immunity_reminders_enabled = true,
        explosion_immunity_reminder_opacity = 0.5,
        explosion_immunity_reminder_size = enums.Sizes.SIZES_SMALL,

        knife_piece_reminders_enabled = true,

        secret_room_placeholder_enabled = true,
        secret_room_placeholder_display_trigger = enums.DisplayTrigger.TRIGGER_EXTRA_INFO,
        secret_room_placeholder_only_hard_to_find_enabled = false,
        secret_room_placeholder_only_clear_rooms_enabled = true,

        near_death_effect_enabled = true,
        near_death_effect_strength = 0.2,
    }
end

-- TODO: while cleaning config, also check if the type is equal, since lua is duck-typed
function Configs.clean_config_from_default(config_tbl)
    local dconf = Configs.get_default_config()

    -- fill up missing configs
    for k, v in pairs(dconf) do
        if config_tbl[k] == nil then
            config_tbl[k] = v
            print("[Reminders] Filled Config: " .. tostring(k))
        end
    end

    -- remove ones that doesnt exist anymore
    for k, _ in pairs(config_tbl) do
        if dconf[k] == nil then
            config_tbl[k] = nil
            print("[Reminders] Removing Config:" .. tostring(k))
        end
    end
end

return Configs
