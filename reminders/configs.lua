-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

local iserializer = require("reminders.iserializer")
local Configs = {}

function Configs.get_default_config()
    return {
        debug_mode = false,

        map_special_colormarks_enabled = true,

        special_color_unvisited = iserializer.encode_color(Color(1, 0, 0)),
        special_color_visited = iserializer.encode_color(Color(0, 1, 0)),
        normal_color_marked = iserializer.encode_color(Color(1, 1, 0)),

        notify_info_enabled = true,
        notify_text_header = "=== ![Missed Special Rooms]! ===",
        notify_text_header_ok = "No Missed Special Rooms :)",
        notify_info_offset = iserializer.encode_vector(Vector(0, 0)),

        icon_scale = 1.5,

        lost_death_icon_enabled = true,
        -- TODO: should specify exactly what offset they meant (Y offset here)
        lost_death_dono_offset = 44.0,
        lost_death_devil_beggar_offset = 22.0,

        door_reminders_enabled = true,

        time_progress_enabled = true,
        time_progress_offset = iserializer.encode_vector(Vector(0, 0)),
        time_progress_opacity = 0.8,
        time_progress_width_percent = 0.2,
        time_progress_opacity_node = 1.0,

        time_progress_boss_rush_icon_enabled = true,
        time_progress_hush_icon_enabled = true,

        game_timer_enabled = true,
        game_timer_offset = iserializer.encode_vector(Vector(0, 0)),
    }
end

return Configs
