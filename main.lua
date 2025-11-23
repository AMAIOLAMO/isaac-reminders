-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

-- The major purpose of this mod is to make things that are not obvious to be more obvious!
-- TODO:
-- 1. add alt path reminders (partially done)
--  -> add different directions of the alt_path arrow
-- 2. icons

-- 3. TIME is past boss rush / hush, should make them fade a bit dark / switch them into nodes / add X to them

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


local alt_arrow = iutils.assert_sprite_load("gfx/reminders/alt_arrow.anm2")

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

local static_sprites = iutils.assert_sprite_load("gfx/reminders/static_sprites.anm2")

-- TODO: this is unstable in the future, we are relying on the game to give things
local card_fronts = iutils.assert_sprite_load("gfx/ui/ui_cardfronts.anm2")
local polaroid_sprite = load_static_png_sprite_16x16("gfx/reminders/sprites/collectibles_327_thepolaroid.png")
local negative_sprite = load_static_png_sprite_16x16("gfx/reminders/sprites/collectibles_328_thenegative.png")

rems.marked_rooms = {}

rems.config = configs.get_default_config()

function rems:reset_config()
    self.config = configs.get_default_config()
    self:log_info("Config has reset")
end

rems.extra_info_timer = timerf.new(0.5, 0)

local RoomNotify = {}
RoomNotify.__index = RoomNotify

function RoomNotify.new(rtype)
    return setmetatable({ type = rtype }, RoomNotify)
end


rems.notify_special_rooms = {}

-- HACK: this is not stable, as it depends on the resources of another mod.
-- But Im lazy, so we have this for now.
if MinimapAPI then
    rems.minimapapi_icons = iutils.assert_sprite_load("gfx/ui/minimapapi_icons.anm2", true)

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

rems.notify_info_timer = timerf.new(5, 5)
rems.notify_info_start_fade = 4

function rems:start_notify_info()
    self:update_notify_rooms()
    self.notify_info_timer:reset()
end

function rems:any_player_has_collectible(type)
    local player_count = game:GetNumPlayers()
    
    for i = 0, player_count - 1 do
        local player = game:GetPlayer(i)

        if player:HasCollectible(type) then
            return true
        end
    end

    return false
end

-- naive way of implementing this
function rems:get_current_room_grid_entities()
    local room = game:GetRoom()
    local idx_count = room:GetGridSize()
    local grid_entities = {}

    for i = 0, idx_count - 1 do
        local grid_entity = room:GetGridEntity(i)

        if grid_entity then
            table.insert(grid_entities, grid_entity)
        end
    end

    return grid_entities
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
    for i in ipairs(self.notify_special_rooms) do
        self.notify_special_rooms[i] = nil
    end


    for _, room in ipairs(unvisited_special_rooms) do
        local desc = room.Descriptor

        -- Curse of the lost will not affect the display flags
        local should_notify = (room:IsVisible() and room:IsIconVisible()) or iutils.is_any_secret_room(room)

        if should_notify then
            table.insert(self.notify_special_rooms, RoomNotify.new(room.Type))
        end

    end

    self:log_debug("Notify rooms updated")
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

function rems:render_notify(alpha)
    local LINE_HEIGHT = 15

    local width = Isaac.GetScreenWidth()

    local config = self:get_config()

    local notify_header = #self.notify_special_rooms == 0 and
        config.notify_text_header_ok or config.notify_text_header
        
    local header_width = Isaac.GetTextWidth(notify_header)

    local offset = iserializer.decode_vector(config.notify_info_offset)

    local global_offset = Vector(0, 50)

    local render_pivot = Vector(
        (width - header_width) / 2 + offset.X, offset.Y
    ) + global_offset

    Isaac.RenderText(
        notify_header,
        render_pivot.X, render_pivot.Y,
        1, 1, 1, alpha
    )

    notify_sprite.Color = Color(1, 1, 1, alpha)
    notify_sprite:SetFrame(notify_sprite:GetDefaultAnimation(), 0)
    notify_sprite:Render(render_pivot + Vector(-32, 0))

    for i, room in ipairs(self.notify_special_rooms) do
        assert(self.minimapapi_roomtype2icon, "Cannot draw icon!")
        local line_height_offset = LINE_HEIGHT * i

        local rname = iutils.room_name_from_type(room.type)

        local icon_id = self.minimapapi_roomtype2icon[room.type]
        local icon = self.minimapapi_icons

        local icon_scale = self:get_config().icon_scale
        local ICON_SIZE = 12
        local icon_fsize = ICON_SIZE * icon_scale

        local name_width = Isaac.GetTextWidth(rname)
        local x_pivot = (width - name_width) / 2

        icon.Color = Color(1, 1, 1, alpha)
        icon:SetFrame(icon_id, 0)
        icon.Scale = Vector(1, 1) * icon_scale
        icon:Render(Vector(x_pivot - icon_fsize, render_pivot.Y + line_height_offset))

        Isaac.RenderText(
            rname,
            x_pivot, render_pivot.Y + line_height_offset,
            1, 1, 1, alpha
        )
    end
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

function rems:direction_to_rotation_deg(dir)
    local rot = 0

    if dir == Direction.LEFT then
        rot = 270
    elseif dir == Direction.RIGHT then
        rot = 90
    elseif dir == Direction.UP then
        rot = 180
    elseif dir == Direction.DOWN then
        rot = 0
    end

    return rot
end

function rems:render_door_reminders()
    local room = game:GetRoom()
    local doors = {}

    -- special doors:
    -- heaven door
    -- sheol trap door
    local game_stage = game:GetLevel():GetStage()

    local has_polaroid = self:any_player_has_collectible(CollectibleType.COLLECTIBLE_POLAROID)
    local has_negative = self:any_player_has_collectible(CollectibleType.COLLECTIBLE_NEGATIVE)

    -- is level right before cathedral / sheol and is a boss room
    if (game_stage == LevelStage.STAGE4_2 or game_stage == LevelStage.STAGE5) and
        room:GetType() == RoomType.ROOM_BOSS then
        local OFFSET = Vector(0, 30)

        if has_polaroid then
            local HEAVEN_DOOR_TYPE = Isaac.GetEntityTypeByName("Heaven Door")
            local HEAVEN_DOOR_VARIANT = Isaac.GetEntityVariantByName("Heaven Door")

            local heaven_doors = Isaac.FindByType(HEAVEN_DOOR_TYPE, HEAVEN_DOOR_VARIANT, 0, true)

            for _, hdoor in ipairs(heaven_doors) do
                local scr_pos = Isaac.WorldToScreen(hdoor.Position)
                static_sprites:SetFrame("ThePolaroid", 0)
                static_sprites.Scale = Vector(0.8, 0.8)
                static_sprites:Render(scr_pos + OFFSET)
            end
        end


        if has_negative then
            local grid_entities = self:get_current_room_grid_entities()

            for _, entity in ipairs(grid_entities) do
                -- is trapdoor?
                if entity:GetType() == GridEntityType.GRID_TRAPDOOR and entity:GetVariant() == 0 then
                    local scr_pos = Isaac.WorldToScreen(entity.Position)

                    static_sprites:SetFrame("TheNegative", 0)
                    static_sprites.Scale = Vector(0.8, 0.8)
                    static_sprites:Render(scr_pos + OFFSET)
                end
            end
        end
    end

    -- Normal doors
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
        local dir = door.Direction
        local rot = self:direction_to_rotation_deg(dir)

        local offset = Vector(0, -self:get_config().door_reminders_yoffset):Rotated(rot)

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
                screen_pos.X, screen_pos.Y
            ) + offset

            alt_arrow.Color = Color.Default
            alt_arrow.Rotation = rot

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
                            screen_pos.X, screen_pos.Y
                        ) + offset

                        maus_knife_sprite:SetFrame("Static_PivotBottom", 0)
                        maus_knife_sprite.Rotation = rot
                        maus_knife_sprite:Render(render_pos)
                    end

                else
                    card_fronts:SetFrame("00_TheFool", 0)

                    local render_pos = Vector(
                        screen_pos.X, screen_pos.Y
                    ) + offset

                    card_fronts.Rotation = rot

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
                    screen_pos.X, screen_pos.Y
                ) + offset

                white_fireplace_notify.Rotation = rot
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
    if self.notify_info_timer:max() == false then
        -- only update the timer when time progress
        if game:IsPaused() == false then
            self.notify_info_timer:tick(self.dt_ms)
        end

        if self:get_config().debug_mode then
            Isaac.RenderText(tostring(self.notify_info_timer.span), 50, 50, 1, 1, 1, 1)
        end

        local alpha = 1

        if self.notify_info_start_fade < self.notify_info_timer.span then
            local fade_progress = (self.notify_info_timer.span - self.notify_info_start_fade) /
                (self.notify_info_timer.max_span - self.notify_info_start_fade)

            alpha = 1 - fade_progress
        end
    
        self:render_notify(alpha)
    end

    if self.extra_info_timer:max() then
        self:render_notify(1.0)
    end
end

local function lerpf(a, b, t)
    return a + (b - a) * t
end

local function lerpv(a, b, t)
    return Vector(
        lerpf(a.X, b.X, t), lerpf(a.Y, b.Y, t)
    )
end

rems.time_progress_anim_pos_offset = Vector(0, 0)

function rems:render_time_progress()
    local w = Isaac.GetScreenWidth()
    local h = Isaac.GetScreenHeight()

    local config = self:get_config()

    local config_offset = iserializer.decode_vector(self:get_config().time_progress_offset)

    local extra_info_fade_opacity = 1.0

    if self.extra_info_timer:max() then
        extra_info_fade_opacity = 0.4
    end

    local opacity = config.time_progress_opacity * extra_info_fade_opacity
    local node_opacity = config.time_progress_opacity_node

    local ANIM_SPEED = 4.0

    local game_time = iutils.get_game_time(game)

    local HIDE_TIME_MINS = 30
    local should_hide = self.extra_info_timer:max() or
        game_time.mins > HIDE_TIME_MINS or game_time.hours > 1

    if should_hide then
        -- TODO HACK instead of -50, we should calculate the difference between current pos with 0
        self.time_progress_anim_pos_offset = lerpv(
            self.time_progress_anim_pos_offset, Vector(0, -50 - config_offset.Y), self.dt_ms * ANIM_SPEED
        )
    else
        self.time_progress_anim_pos_offset = lerpv(
            self.time_progress_anim_pos_offset, Vector(0, 0), self.dt_ms * ANIM_SPEED
        )
    end

    local total_offset = config_offset +
        self.time_progress_anim_pos_offset

    clock_sprite.Color = Color(1, 1, 1, opacity)
    node_tiny.Color = Color(1, 1, 1, opacity * node_opacity)
    boss_rush_icon.Color = Color(1, 1, 1, opacity)
    hush_icon.Color = Color(1, 1, 1, opacity)

    local length = w * config.time_progress_width_percent
    local sections = 30 / 5 -- divide in 5 minutes
    local section_len = length / sections

    for i = 0, sections do
        local node_pos = Vector(
            w / 2 - length / 2 + section_len * i + total_offset.X, 20 + total_offset.Y
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
        w / 2 - length / 2 + length * progress + total_offset.X, 10 + total_offset.Y
    ))
end

function rems:render_game_timer()
    local w = Isaac.GetScreenWidth()
    local game_time = iutils.get_game_time(game)

    local time_str = string.format("%02.0f:%02.0f:%02.0f", game_time.hours, game_time.mins, game_time.secs)

    local offset = iserializer.decode_vector(self:get_config().game_timer_offset)

    if self.extra_info_timer:max() == false then
        Isaac.RenderText(
            time_str,
            w / 2 - Isaac.GetTextWidth(time_str) / 2 + offset.X, 25 + offset.Y, 0.8, 0.8, 0.8, 1
        )
    end
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
        self:reset_config()
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

    self:start_notify_info()
end


function rems:on_post_render()
    local MS2SECS = 1 / 1000
    self.dt_ms = (Isaac.GetTime() - self.prev_frame_time) * MS2SECS

    if not MinimapAPI then
        return
    end

    local config = self:get_config()

    if game:GetHUD():IsVisible() and ModConfigMenu.IsVisible == false then
        self:handle_extra_info_timer()

        if config.door_reminders_enabled then
            self:render_door_reminders()
        end

        if config.lost_death_icon_enabled then
            self:render_lost_death_icon()
        end

        if config.notify_info_enabled then
            self:handle_special_room_notify()
        end

        if config.time_progress_enabled then
            self:render_time_progress()
        end

        if config.game_timer_enabled then
            self:render_game_timer()
        end
    end

    -- KEYBOARD SPECIFIC CONTROLS --
    if config.debug_mode then
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

function rems:on_reset_config()
    self:reset_config()
end

-- MOD CONFIG MENU SUPPORT --

if ModConfigMenu then
    setup_mod_config_menu(MOD_NAME, rems, rems.on_reset_config)
end


-- Callback Registers --
rems:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, rems.on_post_game_started)
rems:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, rems.on_pre_game_exit)

rems:AddCallback(ModCallbacks.MC_POST_RENDER, rems.on_post_render)
rems:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, rems.on_post_new_room)
rems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, rems.on_post_new_floor)
rems:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, rems.on_pre_spawn_clean_award)

rems:AddCallback(ModCallbacks.MC_EXECUTE_CMD, rems.on_execute_cmd)
