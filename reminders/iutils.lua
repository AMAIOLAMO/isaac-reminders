-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix
local enums = require("reminders.enums")

local IUtils = {}

-- Room names
-- TODO: maybe support translation?
IUtils.room_names = {
    [RoomType.ROOM_NULL] = "NULL Room",
    [RoomType.ROOM_DEFAULT] = "Default Room",

    [RoomType.ROOM_ERROR]   = "Error Room",

    [RoomType.ROOM_SECRET]      = "Secret Room",
    [RoomType.ROOM_SUPERSECRET] = "Super Secret Room",
    [RoomType.ROOM_ULTRASECRET] = "Ultra Secret Room",

    [RoomType.ROOM_SHOP]        = "Shop",
    [RoomType.ROOM_TREASURE]    = "Treasure Room",
    [RoomType.ROOM_SACRIFICE]   = "Sacrifice Room",
    [RoomType.ROOM_LIBRARY]     = "Library",
    [RoomType.ROOM_ARCADE]      = "Arcade",
    [RoomType.ROOM_CHALLENGE]   = "Challenge Room",
    [RoomType.ROOM_PLANETARIUM] = "Planetarium",

    [RoomType.ROOM_ISAACS] = "Bedroom",
    [RoomType.ROOM_BARREN] = "Barren Bedroom",

    [RoomType.ROOM_CHEST]    = "Vault Room",
    [RoomType.ROOM_DICE]     = "Dice Room",
    [RoomType.ROOM_CURSE]    = "Curse Room",

    [RoomType.ROOM_DEVIL] = "Devil Room",
    [RoomType.ROOM_ANGEL] = "Angel Room",

    [RoomType.ROOM_DUNGEON] = "Dungeon Room(Crawlspace)",


    [RoomType.ROOM_MINIBOSS] = "Miniboss Room",
    [RoomType.ROOM_BOSS]     = "Boss Room",

    [RoomType.ROOM_SECRET_EXIT] = "Alt Path Room",
    [RoomType.ROOM_BLUE] = "Blue Womb Room",

    -- [RoomType.ROOM_DEATHMATCH] = "Deathmatch room",
}

function IUtils.is_any_secret_room(room_type)
    return (room_type == RoomType.ROOM_SECRET or
        room_type == RoomType.ROOM_SUPERSECRET or
        room_type == RoomType.ROOM_ULTRASECRET)
end

function IUtils.is_normal_room(room_type)
    return room_type == RoomType.ROOM_DEFAULT
end

function IUtils.is_special_room(room_type)
    return room_type ~= RoomType.ROOM_NULL and not IUtils.is_normal_room(room_type)
end

function IUtils.room_desc_is_visible(room_desc)
    return room_desc.DisplayFlags & (1 << 0) ~= 0
end

function IUtils.room_desc_shows_icon(room_desc)
    return room_desc.DisplayFlags & (1 << 2) ~= 0
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
-- returns {
--  total_secs: number, ms: number, secs: number, mins: number, hours: number
-- }
function IUtils.get_game_time(game)
    local total_milliseconds = math.floor(game.TimeCounter * (10 / 3))
    local total_seconds = math.floor(game.TimeCounter / 30)
    local total_minutes = math.floor(total_seconds / 60)
    local total_hours = math.floor(total_minutes / 60)

    return {
        total_secs = total_seconds,
        ms = math.fmod(total_milliseconds, 99),
        secs = math.fmod(total_seconds, 60),
        mins = math.fmod(total_minutes, 60),
        hours = total_hours
    }
end

-- obsolete, will now be utilzing multilingual features
function IUtils.room_name_from_type(room_type, is_boss_challenge)
    if is_boss_challenge and room_type == RoomType.ROOM_CHALLENGE then
        return "Boss Challenge Room"
    else
        return IUtils.room_names[room_type]
    end
end

function IUtils.player_any_of(game, predicate)
    assert(predicate, "Predicate cannot be nil")

    local player_count = game:GetNumPlayers()
    
    for i = 0, player_count - 1 do
        local player = game:GetPlayer(i)

        if predicate(player) then
            return true
        end
    end

    return false
end

function IUtils.any_player_has_collectible(game, type)
    assert(game, "game cannot be nil")
    local player_count = game:GetNumPlayers()
    
    for i = 0, player_count - 1 do
        local player = game:GetPlayer(i)

        if player:HasCollectible(type) then
            return true
        end
    end

    return false
end

function IUtils.any_player_has_card(game, type)
    assert(game, "game cannot be nil")
    local player_count = game:GetNumPlayers()
    
    for i = 0, player_count - 1 do
        local player = game:GetPlayer(i)

        for j = 0, 3 do
            if player:GetCard(j) == type then
                return true
            end
        end
    end

    return false
end


-- types form:
-- {
--      [Card.CARD_CRACKED_KEY] = true,
--      [Card.CARD_XXX] = true,
-- }
-- For fast indexing.
function IUtils.any_player_has_cards(game, types)
    local player_count = game:GetNumPlayers()
    
    for i = 0, player_count - 1 do
        local player = game:GetPlayer(i)

        for j = 0, 3 do
            if types[player:GetCard(j)] ~= nil then
                return true
            end
        end
    end

    return false
end

function IUtils.doorslot_to_dir(door_slot)
    if door_slot == DoorSlot.LEFT0 or door_slot == DoorSlot.LEFT1 then
        return Direction.LEFT
    elseif door_slot == DoorSlot.RIGHT0 or door_slot == DoorSlot.RIGHT1 then
        return Direction.RIGHT
    elseif door_slot == DoorSlot.UP0 or door_slot == DoorSlot.UP1 then
        return Direction.UP
    elseif door_slot == DoorSlot.DOWN0 or door_slot == DoorSlot.DOWN1 then
        return Direction.DOWN
    end

    assert(false, string.format("invalid door_slot given: %d", door_slot))
end

-- calculates the total hit units (aka, how many half red heart damage can isaac take)
-- does not account for lost's invisible half soul heart
function IUtils.get_total_hit_units(player)
    -- black hearts are considered types of soul hearts as well
    -- each bone heart is treated as half a heart
    local soul_heart_count = player:GetSoulHearts()
    local bone_heart_count = player:GetBoneHearts()
    -- somehow rotten hearts are considered 2 units of red hearts by the game
    -- but when u take damage, its' literally half a red heart (aka 1 unit only)
    local rotten_heart_count = player:GetRottenHearts()
    return (player:GetHearts() - rotten_heart_count * 2)
        + soul_heart_count + bone_heart_count + rotten_heart_count
end

-- includes wooden cross, holy mantle, blanket and holy card
function IUtils.get_total_mantle_effect_count(player)
    return (player:GetEffects():HasNullEffect(NullItemID.ID_HOLY_CARD) and 1 or 0) +
        player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
end

function IUtils.get_floor_type(stage, stage_type)
    local ftype = enums.FloorType

    if stage == LevelStage.STAGE1_1 or stage == LevelStage.STAGE1_2 then
        if stage_type == StageType.STAGETYPE_ORIGINAL then
            return ftype.FLOOR_BASEMENT

        elseif stage_type == StageType.STAGETYPE_WOTL then
            return ftype.FLOOR_CELLAR

        elseif stage_type == StageType.STAGETYPE_AFTERBIRTH then
            return ftype.FLOOR_BURNING_BASEMENT

        elseif stage_type == StageType.STAGETYPE_REPENTANCE then
            return ftype.FLOOR_DOWNPOUR

        elseif stage_type == StageType.STAGETYPE_REPENTANCE_B then
            return ftype.FLOOR_DROSS
        end


    elseif stage == LevelStage.STAGE2_1 or stage == LevelStage.STAGE2_2 then
        if stage_type == StageType.STAGETYPE_ORIGINAL then
            return ftype.FLOOR_CAVES

        elseif stage_type == StageType.STAGETYPE_WOTL then
            return ftype.FLOOR_CATACOMBS

        elseif stage_type == StageType.STAGETYPE_AFTERBIRTH then
            return ftype.FLOOR_FLOODED_CAVES

        elseif stage_type == StageType.STAGETYPE_REPENTANCE then
            return ftype.FLOOR_MINES

        elseif stage_type == StageType.STAGETYPE_REPENTANCE_B then
            return ftype.FLOOR_ASHPIT
        end


    elseif stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2 then
        if stage_type == StageType.STAGETYPE_ORIGINAL then
            return ftype.FLOOR_DEPTHS

        elseif stage_type == StageType.STAGETYPE_WOTL then
            return ftype.FLOOR_NECROPOLIS

        elseif stage_type == StageType.STAGETYPE_AFTERBIRTH then
            return ftype.FLOOR_DANK_DEPTHS

        elseif stage_type == StageType.STAGETYPE_REPENTANCE then
            return ftype.FLOOR_MAUSOLEUM

        elseif stage_type == StageType.STAGETYPE_REPENTANCE_B then
            return ftype.FLOOR_GEHENNA
        end


    elseif stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2 then
        if stage_type == StageType.STAGETYPE_ORIGINAL then
            return ftype.FLOOR_WOMB

        elseif stage_type == StageType.STAGETYPE_WOTL then
            return ftype.FLOOR_UTERO

        elseif stage_type == StageType.STAGETYPE_AFTERBIRTH then
            return ftype.FLOOR_SCARRED_WOMB

        elseif stage_type == StageType.STAGETYPE_REPENTANCE then
            return ftype.FLOOR_CORPSE
        end


    elseif stage == LevelStage.STAGE4_3 then
        return ftype.FLOOR_HUSH


    elseif stage == LevelStage.STAGE5 then
        if stage_type == StageType.STAGETYPE_ORIGINAL then
            return ftype.FLOOR_SHEOL

        elseif stage_type == StageType.STAGETYPE_WOTL then
            return ftype.FLOOR_CATHEDRAL
        end


    elseif stage == LevelStage.STAGE6 then
        if stage_type == StageType.STAGETYPE_ORIGINAL then
            return ftype.FLOOR_DARK_ROOM

        elseif stage_type == StageType.STAGETYPE_WOTL then
            return ftype.FLOOR_CHEST
        end


    elseif stage == LevelStage.STAGE7 then
        return ftype.FLOOR_VOID


    elseif stage == LevelStage.STAGE8 then
        return ftype.FLOOR_HOME
    end

    -- fallback
    return ftype.FLOOR_NULL
end

-- from https://wofsauge.github.io/IsaacDocs/rep/RoomDescriptor.html?h=dimension
function IUtils.get_room_desc_dimension(game, room_desc)
    -- 0: main dimension
    -- 1: secondary dimension, used by downpour mirror dimension and mines escape sequence
    -- 2: death certificate dimension
    for i = enums.Dimension.DIM_BEGIN, enums.Dimension.DIM_END do
        if GetPtrHash(room_desc) == GetPtrHash(game:GetLevel():GetRoomByIdx(room_desc.SafeGridIndex, i)) then
            return i
        end
    end

    return -1
end

function IUtils.is_room_desc_mirror_world(game, room_desc)
    local level = game:GetLevel()
    local stage_type = level:GetStageType()
    local stage = level:GetStage()

    local floor_type = IUtils.get_floor_type(stage, stage_type)
    
    return IUtils.get_room_desc_dimension(game, room_desc) == enums.Dimension.DIM_MIRROR_OR_MINES and
        floor_type == enums.FloorType.FLOOR_DOWNPOUR
end

return IUtils
