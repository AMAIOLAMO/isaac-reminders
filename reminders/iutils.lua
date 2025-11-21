-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix
local IUtils = {}

function IUtils.is_any_secret_room(room)
    return room.Descriptor and
        (room.Type == RoomType.ROOM_SECRET or
        room.Type == RoomType.ROOM_SUPERSECRET or
        room.Type == RoomType.ROOM_ULTRASECRET)
end

function IUtils.is_normal_room(room)
    return room.Descriptor and room.Type == RoomType.ROOM_DEFAULT
end

function IUtils.is_special_room(room)
    return room.Descriptor and
        room.Type ~= RoomType.ROOM_NULL and not IUtils.is_normal_room(room)
end

-- extended world to screen that considered mirrored worlds
function IUtils.world_to_screen_ext(pos, mirrored)
    mirrored = mirrored or false

    local screen_pos = Isaac.WorldToScreen(pos)

    if mirrored then
        return Vector(
            Isaac.GetScreenWidth() - screen_pos.X,
            screen_pos.Y
        )
    end

    return screen_pos
end

function IUtils.assert_sprite_loaded(sprite)
    assert(sprite, "sprite is nil")
    assert(sprite:IsLoaded(), "sprite is not loaded")
end

function IUtils.assert_sprite_load(gfx_path, should_load)
    should_load = should_load or true

    local sprite = Sprite()
    sprite:Load(gfx_path, should_load)

    if should_load then
        assert(sprite:IsLoaded(), "sprite is not loaded")
    end
    
    return sprite
end

-- utility to get actual game time
function IUtils.get_game_time(game)
    local total_seconds = math.floor(game.TimeCounter / 30)
    local total_minutes = math.floor(total_seconds / 60)
    local total_hours = math.floor(total_minutes / 60)

    return {
        total_secs = total_seconds,
        secs = math.fmod(total_seconds, 60),
        mins = math.fmod(total_minutes, 60),
        hours = total_hours
    }
end

-- function IUtils.get_room_name_from_type(room_type)
-- end


return IUtils
