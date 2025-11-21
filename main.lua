-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

-- The major purpose of this mod is to make things that are not obvious to be more obvious!
-- TODO:
-- 1. add alt path reminders (partially done)
--  -> add different directions of the alt_path arrow
-- 2. icons

local MOD_NAME = "Reminders"
local rems = RegisterMod(MOD_NAME, 1)

local json = require("reminders.lib.json")
local timerf = require("reminders.timerf")
local iserializer = require("reminders.iserializer")
local ilogger = require("reminders.ilogger")
local iutils = require("reminders.iutils")

local setup_mod_config_menu = require("reminders.setup_mod_config_menu")

-- GAME --
local game = Game()
local sfx_manager = SFXManager()

-- SETUP --
local configs = require("reminders.configs")

local function load_static_png_sprite_16x16(png_path)
    local sprite = Sprite()
    sprite:Load("gfx/reminders/static_16x16.anm2", true)
    sprite:ReplaceSpritesheet(0, png_path)
    sprite:LoadGraphics()

    assert(sprite:IsLoaded(), string.format("png sprite %s is not loaded", png_path))

    return sprite
end


local alt_arrow              = iutils.assert_sprite_load("gfx/reminders/alt_arrow.anm2")

-- TODO: to optimize all of these, we could put all of them in one single spritesheet
-- and have different frames of animation
local notify_sprite          = load_static_png_sprite_16x16("gfx/reminders/sprites/notify.png")
local white_fireplace_notify =  load_static_png_sprite_16x16("gfx/reminders/sprites/white_fireplace_notify.png")
local lost_death_icon        = load_static_png_sprite_16x16("gfx/reminders/sprites/lost_death_icon.png")
local maus_knife_sprite      = load_static_png_sprite_16x16("gfx/reminders/sprites/maus_knife.png")

local node_tiny      = load_static_png_sprite_16x16("gfx/reminders/sprites/node_tiny.png")
local node_regular   = load_static_png_sprite_16x16("gfx/reminders/sprites/node_regular.png")
local clock_sprite   = load_static_png_sprite_16x16("gfx/reminders/sprites/clock.png")
local hush_icon      = load_static_png_sprite_16x16("gfx/reminders/sprites/hush_icon.png")
local boss_rush_icon = load_static_png_sprite_16x16("gfx/reminders/sprites/boss_rush_icon.png")

local card_fronts            = iutils.assert_sprite_load("gfx/ui/ui_cardfronts.anm2")

rems.marked_rooms = {}

rems.config = configs.get_default_config()

rems.extra_info_timer = timerf.new(0.5, 0)

rems.notify_special_rooms = {}
rems.notify_msg = ""
rems.notify_msg_timer = timerf.new(5, 5)
rems.notify_msg_start_fade = 4

-- Room names
-- TODO: maybe support translation?
rems.notify_room_names = {
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

    [RoomType.ROOM_CHEST]       = "Chest Room",
    [RoomType.ROOM_DICE]        = "Dice Room",
    [RoomType.ROOM_CURSE]       = "Curse Room",
    [RoomType.ROOM_MINIBOSS]    = "Miniboss Room",

    [RoomType.ROOM_DEVIL] = "Devil Room",
    [RoomType.ROOM_ANGEL] = "Angel Room",

    [RoomType.ROOM_BOSS] = "Boss Room",
}

-- HACK: this is not stable, as it depends on the resources of another mod.
-- But Im lazy, so we have this for now.
if MinimapAPI then
    rems.minimapapi_icons = Sprite()
    rems.minimapapi_icons:Load("gfx/ui/minimapapi_icons.anm2", true)

    rems.minimapapi_roomtype2icon = {
        [RoomType.ROOM_SECRET] = "IconSecretRoom",
        [RoomType.ROOM_SUPERSECRET] = "IconSuperSecretRoom",
        [RoomType.ROOM_ULTRASECRET] = "IconUltraSecretRoom",

        [RoomType.ROOM_SHOP] = "IconShop",
        [RoomType.ROOM_TREASURE] = "IconTreasureRoom",
        [RoomType.ROOM_SACRIFICE] = "IconSacrificeRoom",
        [RoomType.ROOM_LIBRARY] = "IconLibrary",
        [RoomType.ROOM_ARCADE] = "IconArcade",
        [RoomType.ROOM_CHALLENGE] = "IconChallengeRoom",

        [RoomType.ROOM_ISAACS] = "IconIsaacsRoom",
        [RoomType.ROOM_BARREN] = "IconBarrenRoom",

        [RoomType.ROOM_CHEST] = "IconChestRoom",
        [RoomType.ROOM_DICE] = "IconDiceRoom",
        [RoomType.ROOM_PLANETARIUM] = "IconPlanetarium",
        [RoomType.ROOM_CURSE] = "IconCurseRoom",
        [RoomType.ROOM_MINIBOSS] = "IconMiniboss",

        [RoomType.ROOM_DEVIL] = "IconDevilRoom",
        [RoomType.ROOM_ANGEL] = "IconAngelRoom",

        [RoomType.ROOM_BOSS] = "IconBoss",
    }
end

rems.dt_ms = 0
rems.prev_frame_time = 0.0

-- simple implementation of shallow copy
-- function table.shallow_copy(tbl)
--   local new_tbl = {}
--
--   for k,v in pairs(tbl) do
--     new_tbl[k] = v
--   end
--
--   return new_tbl
-- end


-- DEBUG --
function rems:log_debug(fmt, ...)
    if self:get_config().debug_mode then
        local time_str = tostring(Isaac.GetTime())
        local result_msg = arg and
            string.format(fmt, table.unpack(arg)) or fmt
        print(
            string.format("[DBG][%s][%s]: %s", MOD_NAME, time_str, result_msg)
        )
    end
end

function rems:log_info(fmt, ...)
    local time_str = tostring(Isaac.GetTime())

    local result_msg = arg and
    string.format(fmt, table.unpack(arg)) or fmt
    print(
        string.format("[INFO][%s][%s]: %s", MOD_NAME, time_str, result_msg)
    )
end

-- MAIN PROCEDURES --
function rems:get_config()
    assert(self.config, "config is nil")
    return self.config
end

function rems:start_notify_msg(msg)
    self.notify_msg = msg
    self.notify_msg_timer:reset()
end

function rems:refresh_notify_msg_timer()
    self.notify_msg_timer:reset()
end

function rems:mark_room(room)
    self.marked_rooms[room.Position] = {
        pos = room.Position,
        original_color = room.Color
    }

    room.Color = iserializer.decode_color(self:get_config().normal_color_marked)
end

function rems:unmark_room(room)
    room.Color = self.marked_rooms[room.Position].original_color
    self.marked_rooms[room.Position] = nil
end

function rems:is_room_marked(room)
    return self.marked_rooms[room.Position] ~= nil
end


function rems:update_room_color_marks()
    local special_rooms = {}

    for _, room in ipairs(MinimapAPI:GetLevel()) do
        if iutils.is_special_room(room) then
            table.insert(special_rooms, room)
            -- probably make this customizable?
            local room_visit_count = room.Descriptor.VisitedCount

            local config = self:get_config()

            -- Special Case for Miniboss (as it is an ambush >:D)  and rooms with icons not visible
            if room.Type == RoomType.ROOM_MINIBOSS or room:IsIconVisible() == false then
                if room:IsVisited() then
                    room.Color = iserializer.decode_color(config.special_color_visited)
                end
            else
                room.Color = room:IsVisited() and
                    iserializer.decode_color(config.special_color_visited) or
                        iserializer.decode_color(config.special_color_unvisited)
            end
        end
    end

    -- debug purposes only
    local output_str = "Found special rooms at locations: {"
    for _, room in ipairs(special_rooms) do
        output_str = output_str .. string.format("<%d, %d>, ", room.Position.X, room.Position.Y)
    end

    output_str = output_str .. "}"

    self:log_debug(output_str)
end

function rems:get_unvisited_special_rooms()
    assert(MinimapAPI, "Cannot find MinimapAPI!")
    local rooms = {}
    
    for _, room in ipairs(MinimapAPI:GetLevel()) do
        if iutils.is_special_room(room) and room:IsVisited() == false then
            table.insert(rooms, room)
        end
    end

    return rooms
end

function rems:update_notify_rooms()
    local unvisited_special_rooms = self:get_unvisited_special_rooms()

    for _, room in ipairs(unvisited_special_rooms) do
        local desc = room.Descriptor

        local room_name = self.notify_room_names[room.Type]

        -- Curse of the lost will not affect the display flags
        local should_notify = (room:IsVisible() and room:IsIconVisible()) or iutils.is_any_secret_room(room)

        if room_name ~= nil and should_notify then
            table.insert(self.notify_special_rooms, {
                type = room.Type,
                name = room_name
            })
        end

    end

    self:log_debug("Notify rooms updated")
end

function rems:get_notify_msg_with_unvisited_special_rooms()
    local notify_msg = self:get_config().notify_text_header

    local unvisited_special_rooms = self:get_unvisited_special_rooms()

    for _, room in ipairs(unvisited_special_rooms) do
        local desc = room.Descriptor

        local room_name = self.notify_room_names[room.Type]

        if self:get_config().debug_mode then
            notify_msg = string.format("%s\n--> room_name: %s, display_flags: %d", notify_msg, room_name or "NIL", room:GetDisplayFlags())
        else
            -- Curse of the lost will not affect the display flags
            local should_notify = (room:IsVisible() and room:IsIconVisible()) or iutils.is_any_secret_room(room)

            if room_name ~= nil and should_notify then
                notify_msg = string.format("%s\n--> %s", notify_msg, room_name)
            end
        end

    end

    return notify_msg
end

function rems:notify_unvisited_special_rooms()
    local msg = self:get_notify_msg_with_unvisited_special_rooms()
    self:update_notify_rooms()

    self:start_notify_msg(msg)
end

function rems:render_room_icon(room_type, pos)
    assert(self.minimapapi_icons and self.minimapapi_roomtype2icon, "Minimapapi icons are not loaded")
    local icon_anm_name = self.minimapapi_roomtype2icon[room_type]
    assert(icon_anm_name, "Cannot find associate roomtype: " .. tostring(room_type) .. "and their icon")

    local icons = self.minimapapi_icons
    local icon_scale = self:get_config().icon_scale

    icons:SetFrame(icon_anm_name, 0)
    icons.Scale = Vector(icon_scale, icon_scale)
    icons:Render(pos)
end

-- TODO: rewrite this so that the notify_msg actually contains useful information of
-- each room to render, so we can also handle line height, displaying icons and more
function rems:render_notify(alpha)
    local width = Isaac.GetScreenWidth()
    local text_width = Isaac.GetTextWidth(self:get_config().notify_text_header)

    local offset = iserializer.decode_vector(self:get_config().notify_msg_offset)

    notify_sprite.Color = Color(1, 1, 1, alpha)
    notify_sprite:SetFrame(notify_sprite:GetDefaultAnimation(), 0)
    notify_sprite:Render(Vector(
        (width - text_width) / 2 - 32 + offset.X, 50 + offset.Y
    ))

    Isaac.RenderText(self.notify_msg, (width - text_width) / 2 + offset.X, 50 + offset.Y, 1, 1, 1, alpha)
end

function rems:render_lost_death_icon()
    local player = Isaac.GetPlayer()
    
    -- touched by white fire, turned into the lost
    local is_lost_curse_effect = player:GetEffects():HasNullEffect(112)
    
    -- devil beggars are slot machines :P
    local devil_beggars = Isaac.FindByType(EntityType.ENTITY_SLOT, 5, -1, true, false)
    local blood_donos = Isaac.FindByType(EntityType.ENTITY_SLOT, 2, -1, true, false)

    if player:GetPlayerType() == PlayerType.PLAYER_THELOST or
        player:GetPlayerType() == PlayerType.PLAYER_THELOST_B or is_lost_curse_effect then

        lost_death_icon:SetFrame("Static_PivotBottom", 0)

        local config = self:get_config()

        for _, devil_beggar in ipairs(devil_beggars) do
            local is_mirror = game:GetRoom():IsMirrorWorld()
            local screen_pos = iutils.world_to_screen_ext(devil_beggar.Position, is_mirror)

            lost_death_icon:Render(Vector(
                screen_pos.X, screen_pos.Y - config.lost_death_devil_beggar_offset
            ))
        end

        for _, dono in ipairs(blood_donos) do
            local screen_pos = Isaac.WorldToScreen(dono.Position)

            lost_death_icon:Render(Vector(
                screen_pos.X, screen_pos.Y - config.lost_death_dono_offset
            ))
        end
    end

end

function rems:render_door_reminders()
    local room = game:GetRoom()
    local doors = {}

    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door then
            table.insert(doors, door)
        end
    end

    for _, door in ipairs(doors) do
        local is_mirror = game:GetRoom():IsMirrorWorld()
        local screen_pos = iutils.world_to_screen_ext(door.Position, is_mirror)
        local player = Isaac.GetPlayer()

        if self:get_config().debug_mode then
            Isaac.RenderText(
                string.format(
                    "Type.Variant: %d.%d\nPos: <%.2f, %.2f>\nState: %d, VarData: %d\nCurrentRoomType: %d\nTargetRoomType: %d",
                        door:GetType(), door:GetVariant(), door.Position.X, door.Position.Y,
                        door.State, door.VarData, door.CurrentRoomType, door.TargetRoomType
                ),
                screen_pos.X, screen_pos.Y, 1, 1, 1, 1
            )
        end

        -- TODO: based on direction, rotate the sprite's pivot point
        -- alt path doors mark
        if door.TargetRoomType == RoomType.ROOM_SECRET_EXIT then
            alt_arrow:Play("Idle")
            alt_arrow:Update()

            local render_pos = Vector(
                screen_pos.X, screen_pos.Y - 20
            )

            alt_arrow.Color = Color.Default

            alt_arrow:Render(render_pos)
        end

        -- special boss door fool card on special stage
        
        -- TODO: edge case -> gehenna does not have ascent door
        local level = game:GetLevel()
        if door.TargetRoomType == RoomType.ROOM_BOSS then

            local is_mausoleum_meat_door = door:GetType() == 16 and door:GetVariant() == 3

            -- is in mom's floor (possible XL floor edge case)
            if level:GetStage() == LevelStage.STAGE3_2 then
                local has_all_knife_pieces = player:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) and
                    player:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)

                if is_mausoleum_meat_door then
                    if has_all_knife_pieces then
                        local render_pos = Vector(
                            screen_pos.X, screen_pos.Y - 20
                        )

                        maus_knife_sprite:SetFrame("Static_PivotBottom", 0)
                        maus_knife_sprite:Render(render_pos)
                    end

                else
                    card_fronts:SetFrame("00_TheFool", 0)

                    local render_pos = Vector(
                        screen_pos.X, screen_pos.Y - 20
                    )
                    card_fronts:Render(render_pos)
                end
            end

        end


        -- curse door white fire in downpour / dross specifically
        local player_type = Isaac.GetPlayer():GetPlayerType()

        -- only display white fire when they are not the lost (since there is no reason to touch white fire)
        if player_type ~= PlayerType.PLAYER_THELOST and player_type ~= PlayerType.PLAYER_THELOST_B then
            if door.TargetRoomType == RoomType.ROOM_CURSE and
                level:GetStage() == LevelStage.STAGE1_2 and
                (level:GetStageType() == StageType.STAGETYPE_REPENTANCE or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B) then
                white_fireplace_notify:SetFrame("Static_PivotBottom", 0)


                local render_pos = Vector(
                    screen_pos.X, screen_pos.Y - 20
                )

                white_fireplace_notify:Render(render_pos)
            end
        end

    end
end

function rems:handle_extra_info_timer()
    local main_player = Isaac.GetPlayer()

    if Input.GetActionValue(ButtonAction.ACTION_MAP, main_player.ControllerIndex) >= 0.5 then
        if self:get_config().debug_mode then
            Isaac.RenderText(tostring(self.extra_info_timer.span), 50, 50, 1, 1, 1, 1)
        end

        self.extra_info_timer:tick_max(self.dt_ms)

    else
        self.extra_info_timer:reset()
    end
end

function rems:handle_special_room_notify()
    if self.notify_msg_timer:max() == false then
        -- only update the timer when time progress
        if game:IsPaused() == false then
            self.notify_msg_timer:tick(self.dt_ms)
        end

        if self:get_config().debug_mode then
            Isaac.RenderText(tostring(self.notify_msg_timer.span), 50, 50, 1, 1, 1, 1)
        end

        local alpha = 1

        if self.notify_msg_start_fade < self.notify_msg_timer.span then
            local fade_progress = (self.notify_msg_timer.span - self.notify_msg_start_fade) /
                (self.notify_msg_timer.max_span - self.notify_msg_start_fade)

            alpha = 1 - fade_progress
        end
    
        self:render_notify(alpha)
    end

    if self.extra_info_timer:max() then
        self:render_notify(1.0)
    end
end

function rems:render_time_progress()
    local w = Isaac.GetScreenWidth()
    local h = Isaac.GetScreenHeight()

    local config = self:get_config()

    local opacity = config.time_progress_opacity
    local node_opacity = config.time_progress_opacity_node

    local offset = iserializer.decode_vector(self:get_config().time_progress_offset)

    clock_sprite.Color = Color(1, 1, 1, opacity)
    node_tiny.Color = Color(1, 1, 1, opacity * node_opacity)
    boss_rush_icon.Color = Color(1, 1, 1, opacity)
    hush_icon.Color = Color(1, 1, 1, opacity)

    local length = w * config.time_progress_width_percent
    local sections = 30 / 5 -- divide in 5 minutes
    local section_len = length / sections

    local game_time = iutils.get_game_time(game)

    for i = 0, sections do
        local node_pos = Vector(
            w / 2 - length / 2 + section_len * i + offset.X, 20 + offset.Y
        )

        -- boss rush
        if i == (25 / 5) and config.time_progress_boss_rush_icon_enabled then
            boss_rush_icon:SetFrame("Static_Center", 0)
            boss_rush_icon:Render(node_pos)

        -- hush
        elseif i == (30 / 5) and config.time_progress_hush_icon_enabled then
            hush_icon:SetFrame("Static_Center", 0)
            hush_icon:Render(node_pos)

        else
            node_tiny:SetFrame("Static_Center", 0)
            node_tiny:Render(node_pos)
        end
    end

    local hush_time_secs = 30 * 60

    local progress = math.min(game_time.total_secs, hush_time_secs) / hush_time_secs

    clock_sprite:SetFrame("Static_Center", 0)
    clock_sprite:Render(Vector(
        w / 2 - length / 2 + length * progress + offset.X, 10 + offset.Y
    ))
end

function rems:render_game_timer()
    local w = Isaac.GetScreenWidth()
    local game_time = iutils.get_game_time(game)

    local time_str = string.format("%02.0f:%02.0f:%02.0f", game_time.hours, game_time.mins, game_time.secs)

    local offset = iserializer.decode_vector(self:get_config().game_timer_offset)

    Isaac.RenderText(
        time_str,
        w / 2 - Isaac.GetTextWidth(time_str) / 2 + offset.X, 25 + offset.Y, 0.8, 0.8, 0.8, 1
    )
end

-- CALLBACKS --

function rems:on_post_game_started()
    self:log_debug("Game started")

    self.prev_frame_time = Isaac.GetTime()

    if self:HasData() then
        local json_data = self:LoadData()
        self:log_debug(string.format("Loading data: %s", json_data))
        local new_config_data = json.decode(json_data)
        self.config = new_config_data
        self:log_debug(string.format("Data loaded"))
    end

    if card_fronts:IsLoaded() then
        self:log_info("Loaded card sprites.")
    else
        self:log_info("[warning] Cannot load card sprites.")
    end

    if white_fireplace_notify:IsLoaded() then
        self:log_info("Loaded white fireplace sprites.")
    else
        self:log_info("[warning] Cannot load white fireplace sprites.")
    end

    if lost_death_icon:IsLoaded() then
        self:log_info("Loaded lost death icon.")
    else
        self:log_info("[warning] Cannot load lost death icon.")
    end

    -- should load
    if MinimapAPI then
        self:log_info("Minimap Found.")
        local config = self:get_config()

        if config.map_special_colormarks_enabled then
            self:update_room_color_marks()
        end

        self:log_debug("Updated rooms")

        if self.minimapapi_icons and self.minimapapi_icons:IsLoaded() then
            self:log_info("Minimapapi icons loaded")
        end
    else
        self:log_info("Minimap Not Found.")
    end
end

function rems:on_pre_game_exit()
    -- should save
    assert(self:get_config(), "Cannot save data because config is nil")
    local json_data = json.encode(self:get_config())
    self:log_debug(string.format("Saving data: %s", json_data))
    self:SaveData(json_data)
end

function rems:on_execute_cmd(command, args)
    if command == "REMS_ResetConfig" then
        self.config = configs.get_default_config()
        self:log_info("Config has reset: %s", json.encode(self.config))
    end
end

function rems:on_post_new_room()
    if not MinimapAPI then
        return
    end
    -- else
    
    -- update rooms
    if self:get_config().map_special_colormarks_enabled then
        self:update_room_color_marks()
    end

    self:update_notify_rooms()

    self.notify_msg = self:get_notify_msg_with_unvisited_special_rooms()

    if self:get_config().debug_mode then
        self:log_debug("Updated room marks")
        self:log_debug("Updated notify msg")
    end

    local newmap_room = MinimapAPI:GetCurrentRoom()
    local isaac_room = game:GetRoom()

    if newmap_room ~= nil and iutils.is_special_room(newmap_room) and isaac_room:IsMirrorWorld() == false then
        -- are all rooms automatically visited if we go into a new room?
        -- what about special case such as glowing hourglass?
        if newmap_room:IsVisited() then
            newmap_room.Color = iserializer.decode_color(self:get_config().special_color_visited)
        end
    end
end

function rems:on_post_new_floor()
    if not MinimapAPI then
        return
    end
    -- else
    
    -- clear entries on new floor
    local marked_rooms_size = #self.marked_rooms
    for k, v in ipairs(self.marked_rooms) do
        self.marked_rooms[k] = nil
    end

    self:log_debug("new floor entered, cleared all marks")

    if self:get_config().map_special_colormarks_enabled then
        self:update_room_color_marks()
    end

    self:log_debug("Updated Room marks")
end

function rems:on_pre_spawn_clean_award(_rng)
    if not MinimapAPI then
        return
    end
    -- else

    -- recommended by discord users: shows a big arrow and add audio cues
    self:update_notify_rooms()
    self.notify_msg = self:get_notify_msg_with_unvisited_special_rooms()

    if self:get_config().map_special_colormarks_enabled then
        self:update_room_color_marks()
    end

    local current_room = MinimapAPI:GetCurrentRoom()

    -- TODO: Handle void floor differently, as it could be annoying to show up everytime
    -- TODO: handle mirror floors differently, although Im still unsure on how to
    -- Check whether or not it has been seen in the normal world
    if current_room ~= nil and current_room.Type == RoomType.ROOM_BOSS then
        self:on_boss_completed(current_room)
    end
end

function rems:on_boss_completed(boss_room)
    if not MinimapAPI then
        return
    end

    self:log_debug("BOSS COMPLETED, NOTIFY PLAYER ABOUT MISSED SPECIAL ROOMS")

    self:notify_unvisited_special_rooms()
end


function rems:on_post_render()
    local MS2SECS = 1 / 1000
    self.dt_ms = (Isaac.GetTime() - self.prev_frame_time) * MS2SECS

    if not MinimapAPI then
        return
    end

    local config = self:get_config()

    self:handle_extra_info_timer()

    if config.door_reminders_enabled then
        self:render_door_reminders()
    end

    if config.lost_death_icon_enabled then
        self:render_lost_death_icon()
    end

    if config.notify_msg_enabled then
        self:handle_special_room_notify()
    end

    if config.time_progress_enabled then
        self:render_time_progress()
    end

    if config.game_timer_enabled then
        self:render_game_timer()
    end

    -- KEYBOARD SPECIFIC CONTROLS --
    -- TODO: add remapping ability utilizing Mod Config Menu
    if config.debug_mode then
        if Input.IsButtonTriggered(Keyboard.KEY_G, 0) then
            self:notify_unvisited_special_rooms()
        end

        if Input.IsButtonTriggered(Keyboard.KEY_N, 0) then
            self:log_debug("N pressed, toggle marking of room")
            local current_room = MinimapAPI:GetCurrentRoom()

            if self:is_room_marked(current_room) then
                self:unmark_room(current_room)
                self:log_debug("room unmarked")
            else
                self:mark_room(current_room)
                self:log_debug("room marked")
            end
        end

    end


    self.prev_frame_time = Isaac.GetTime()
end

-- MOD CONFIG MENU SUPPORT --

if ModConfigMenu then
    setup_mod_config_menu(MOD_NAME, rems)
end


-- Callback Registers --
rems:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, rems.on_post_game_started)
rems:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, rems.on_pre_game_exit)

rems:AddCallback(ModCallbacks.MC_POST_RENDER, rems.on_post_render)
rems:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, rems.on_post_new_room)
rems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, rems.on_post_new_floor)
rems:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, rems.on_pre_spawn_clean_award)

rems:AddCallback(ModCallbacks.MC_EXECUTE_CMD, rems.on_execute_cmd)
