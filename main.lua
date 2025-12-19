-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

-- The major purpose of this mod is to make things that are not obvious to be more obvious!
-- TODO: remove full dependency towards miniMAPI

-- BUG: Mini bosses with treasure map does not display color marks still, even if the icon is visible.

local MOD_NAME = "Reminders"
local rems = RegisterMod(MOD_NAME, 1)

local json         = include("reminders.lib.json")
local timerf       = include("reminders.timerf")
local iserializer  = include("reminders.iserializer")
local ilogger      = include("reminders.ilogger")
local iutils       = include("reminders.iutils")
local enums        = include("reminders.enums")
local offset_stack = include("reminders.offset_stack")

local setup_mod_config_menu = include("reminders.setup_mod_config_menu")

-- GAME --
local game = Game()
local sfx_manager = SFXManager()

-- SETUP --
local configs = include("reminders.configs")

local function lerpf(a, b, t)
    return a + (b - a) * t
end

local function lerpv(a, b, t)
    return Vector(
        lerpf(a.X, b.X, t), lerpf(a.Y, b.Y, t)
    )
end

-- maps a value from one range to another linearly
local function mapf(v, a1, b1, a2, b2)
    return ((v - a1) / (b1 - a1)) * (b2 - a2) + a2
end


local function load_static_png_sprite_16x16(png_path)
    local sprite = Sprite()
    sprite:Load("gfx/reminders/static_16x16.anm2", true)
    sprite:ReplaceSpritesheet(0, png_path)
    sprite:LoadGraphics()

    assert(sprite:IsLoaded(), string.format("png sprite %s is not loaded", png_path))

    return sprite
end


local minimap_icons = iutils.assert_sprite_load("gfx/reminders/minimap_icons.anm2")

-- TODO: to optimize all of these, we could put all of them in one single spritesheet
-- and have different frames of animation
local notify_sprite          = load_static_png_sprite_16x16("gfx/reminders/sprites/notify.png")
local white_fireplace_notify = load_static_png_sprite_16x16("gfx/reminders/sprites/white_fireplace_notify.png")
local lost_death_icon        = load_static_png_sprite_16x16("gfx/reminders/sprites/lost_death_icon.png")

local node_tiny      = load_static_png_sprite_16x16("gfx/reminders/sprites/node_tiny.png")
local clock_sprite   = load_static_png_sprite_16x16("gfx/reminders/sprites/clock.png")
local hush_icon      = load_static_png_sprite_16x16("gfx/reminders/sprites/hush_icon.png")
local boss_rush_icon = load_static_png_sprite_16x16("gfx/reminders/sprites/boss_rush_icon.png")

local secret_room_placeholder = iutils.assert_sprite_load("gfx/reminders/secret_room_placeholder.anm2")

local static_sprites = iutils.assert_sprite_load("gfx/reminders/static_sprites.anm2")

-- useful function to render static sprites that automatically reset's certain settings
-- data: pos, color, scale, rot
local function render_static_sprite(anim_name, frame, data)
    assert(data.pos, "Rendering static sprite without providing pos data")
    data.color = data.color or Color.Default
    data.scale = data.scale or Vector.One
    data.rot = data.rot or 0

    static_sprites.Color = data.color
    static_sprites.Scale = data.scale
    static_sprites.Rotation = data.rot

    static_sprites:SetFrame(anim_name, frame)
    static_sprites:Render(data.pos)
end

-- TODO: this is unstable in the future, we are relying on the game to give things
local card_fronts = iutils.assert_sprite_load("gfx/ui/ui_cardfronts.anm2")

rems.config = configs.get_default_config()



function rems:reset_config()
    self.config = configs.get_default_config()
    self:log_info("Config has reset")
end

rems.extra_info_timer = timerf.new(0.5, 0)

local RoomNotify = {}
RoomNotify.__index = RoomNotify

function RoomNotify.new(rtype, rcount)
    return setmetatable({ type = rtype, count = rcount }, RoomNotify)
end


rems.notify_special_rooms = {}
rems.roomtype2icon = {
    [RoomType.ROOM_SECRET]      = "IconSecretRoom",
    [RoomType.ROOM_SUPERSECRET] = "IconSuperSecretRoom",
    [RoomType.ROOM_ULTRASECRET] = "IconUltraSecretRoom",

    [RoomType.ROOM_SHOP]        = "IconShop",
    [RoomType.ROOM_TREASURE]    = "IconTreasureRoom",
    [RoomType.ROOM_SACRIFICE]   = "IconSacrificeRoom",
    [RoomType.ROOM_LIBRARY]     = "IconLibrary",
    [RoomType.ROOM_ARCADE]      = "IconArcade",
    [RoomType.ROOM_CHALLENGE]   = "IconAmbushRoom", -- TODO: add boss challenge room support

    [RoomType.ROOM_ISAACS]      = "IconIsaacsRoom",
    [RoomType.ROOM_BARREN]      = "IconBarrenRoom",

    [RoomType.ROOM_CHEST]       = "IconChestRoom",
    [RoomType.ROOM_DICE]        = "IconDiceRoom",
    [RoomType.ROOM_PLANETARIUM] = "IconPlanetarium",
    [RoomType.ROOM_CURSE]       = "IconCurseRoom",
    [RoomType.ROOM_MINIBOSS]    = "IconMiniboss",

    [RoomType.ROOM_DEVIL]       = "IconDevilRoom",
    [RoomType.ROOM_ANGEL]       = "IconAngelRoom",

    [RoomType.ROOM_BOSS]        = "IconBoss",
}

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

rems.notify_info_timer = timerf.new(3, 3)

function rems:start_notify_info()
    self:update_notify_rooms()
    self.notify_info_timer:reset()
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


function rems:try_minimap_update_room_color_marks()
    if not MinimapAPI then
        return false
    end

    local special_rooms = {}

    -- TODO: Minimap dependency
    for _, room in ipairs(MinimapAPI:GetLevel()) do
        if iutils.is_special_room(room.Type) then
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

    return true
end

function rems:get_unvisited_special_room_descs()
    local result_descs = {}

    local room_descs = game:GetLevel():GetRooms()

    for i = 0, room_descs.Size - 1 do
        local room_desc = room_descs:Get(i)

        local visible_flag = 1 << 0

        if iutils.is_special_room(room_desc.Data.Type) and room_desc.VisitedCount == 0
            and (room_desc.DisplayFlags & visible_flag) ~= 0 then
            table.insert(result_descs, room_desc)
        end
    end

    return result_descs
end

function rems:update_notify_rooms()
    local room_descs = self:get_unvisited_special_room_descs()

    for k, _ in pairs(self.notify_special_rooms) do
        self.notify_special_rooms[k] = nil
    end

    -- may require updating the notify rooms during pickup of collectible & cards
    local can_open_ultra_secret = iutils.any_player_has_collectible(game, CollectibleType.COLLECTIBLE_RED_KEY)
        or iutils.any_player_has_card(game, Card.CARD_CRACKED_KEY) or iutils.any_player_has_card(game, Card.CARD_SOUL_CAIN)


    for _, desc in ipairs(room_descs) do
        local room_type = desc.Data.Type
        -- Curse of the lost will not affect the display flags
        local should_notify = (iutils.room_desc_is_visible(desc) and iutils.room_desc_shows_icon(desc))
            or iutils.is_any_secret_room(desc.Data.Type)

        -- dont ultra secret when we dont have these collectibles
        if self:get_config().notify_info_conditional_ultra_secret and
            (room_type == RoomType.ROOM_ULTRASECRET and can_open_ultra_secret == false) then
            should_notify = false
        end

        if should_notify then
            if self.notify_special_rooms[room_type] == nil then
                self.notify_special_rooms[room_type] = RoomNotify.new(room_type, 1)
            else
                self.notify_special_rooms[room_type].count = 
                    self.notify_special_rooms[room_type].count + 1
            end
        end

    end

    self:log_debug("Notify rooms updated")
end

function rems:render_room_icon(room_type, pos)
    local icon_anm_name = self.roomtype2icon[room_type]
    assert(icon_anm_name, "Cannot find associate roomtype: " .. tostring(room_type) .. "and their icon")

    local icons = minimap_icons
    local icon_scale = self:get_config().icon_scale

    icons:SetFrame(icon_anm_name, 0)
    icons.Scale = Vector(icon_scale, icon_scale)
    icons:Render(pos)
end

function rems:render_notify(alpha)
    local width = Isaac.GetScreenWidth()

    local config = self:get_config()

    local line_height = config.notify_info_line_height
    local text_scale = config.notify_info_text_scale
    local opacity = config.notify_info_opacity
    alpha = alpha * opacity

    local notify_text_header = "=== ![Missed Special Rooms]! ==="
    local notify_text_header_ok = "No Missed Special Rooms :)"

    local special_room_count = 0

    for _k, _v in pairs(self.notify_special_rooms) do
        special_room_count = special_room_count + 1
    end
    
    -- fallback to a solution
    local notify_header = special_room_count > 0 and
        notify_text_header or notify_text_header_ok
        or "Notify header is somehow nil! Reset Config to fix this."
        
    local header_width = Isaac.GetTextWidth(notify_header) * text_scale

    local offset = iserializer.decode_vector(config.notify_info_offset)

    local global_offset = Vector(0, 50)

    local render_pivot = Vector(
        (width - header_width) / 2 + offset.X, offset.Y
    ) + global_offset

    local OK_COLOR = Color(0.5, 0.9, 0.4, 1)
    local MISSING_COLOR = Color(0.9, 0.5, 0.4, 1)

    local header_color = special_room_count > 0 and MISSING_COLOR or OK_COLOR

    Isaac.RenderScaledText(
        notify_header,
        render_pivot.X, render_pivot.Y,
        text_scale, text_scale,
        header_color.R, header_color.G, header_color.B, alpha
    )

    notify_sprite.Color = Color(1, 1, 1, alpha)
    notify_sprite:SetFrame(notify_sprite:GetDefaultAnimation(), 0)

    -- left 
    notify_sprite:Render(render_pivot + Vector(-16, 0))
    
    -- right
    notify_sprite:Render(render_pivot + Vector(header_width, 0))

    local room_idx = 0
    for k, room in pairs(self.notify_special_rooms) do
        assert(self.roomtype2icon, "Cannot draw icon!")
        -- +1 for header
        local line_height_offset = line_height * (room_idx + 1)

        -- fall back to displaying room type
        local rname = iutils.room_name_from_type(room.type) or
            ("NIL ROOM of type: " .. room.type)

        local rlabel = rname

        if room.count > 1 then
            rlabel = string.format("%s x%d", rlabel, room.count)
        end

        -- default fall back icon to secret room icon
        local icon_id = self.roomtype2icon[room.type] or
            self.roomtype2icon[RoomType.ROOM_SECRET]

        local icons = minimap_icons

        local icon_scale = self:get_config().icon_scale
        local BASE_ICON_SIZE = 12
        local icon_fsize = BASE_ICON_SIZE * icon_scale

        local name_width = Isaac.GetTextWidth(rlabel) * text_scale

        -- TODO: add special ICON ONLY way of grid align of icons
        if config.notify_info_type == enums.NotifyInfoType.NOTIFY_ICON then
            icons.Color = Color(1, 1, 1, alpha)
            icons:SetFrame(icon_id, 0)
            icons.Scale = Vector(1, 1) * icon_scale
            local x_pivot = render_pivot.X + header_width * 0.5
                - (special_room_count * icon_fsize * 0.5) + icon_fsize * room_idx

            icons:Render(
                Vector(x_pivot, render_pivot.Y + line_height)
            )
        end

        -- TODO: if both are true, then we have to render it normally
        if config.notify_info_type == enums.NotifyInfoType.NOTIFY_ICON_TEXT then
            icons.Color = Color(1, 1, 1, alpha)
            icons:SetFrame(icon_id, 0)
            icons.Scale = Vector(1, 1) * icon_scale

            local x_pivot = render_pivot.X + (header_width / 2) - (name_width / 2) - icon_fsize

            icons:Render(
                Vector(x_pivot, render_pivot.Y + line_height_offset)
            )
        end

        if config.notify_info_type & enums.NotifyInfoType.NOTIFY_TEXT ~= 0 then
            local x_pivot = render_pivot.X + (header_width / 2) - (name_width / 2)
            Isaac.RenderScaledText(
                rlabel,
                x_pivot, render_pivot.Y + line_height_offset,
                text_scale, text_scale,
                1, 1, 1, alpha
            )
        end

        room_idx = room_idx + 1
    end
end

function rems:render_lost_death_icon()
    local player = Isaac.GetPlayer()
    
    -- touched by white fire, turned into the lost
    local is_lost_curse_effect = player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE)

    -- devil beggars are slot machines :P
    local devil_beggars = Isaac.FindByType(EntityType.ENTITY_SLOT, 5, -1, true, false)
    local blood_donos = Isaac.FindByType(EntityType.ENTITY_SLOT, 2, -1, true, false)

    if player:GetPlayerType() == PlayerType.PLAYER_THELOST or
        player:GetPlayerType() == PlayerType.PLAYER_THELOST_B or is_lost_curse_effect then

        lost_death_icon:SetFrame("Static_PivotBottom", 0)

        local config = self:get_config()

        for _, devil_beggar in ipairs(devil_beggars) do
            local is_mirror = game:GetRoom():IsMirrorWorld()
            local scr_pos = iutils.world_to_screen_ext(devil_beggar.Position, is_mirror)

            lost_death_icon:Render(Vector(
                scr_pos.X, scr_pos.Y - config.lost_death_devil_beggar_offset
            ))
        end

        for _, dono in ipairs(blood_donos) do
            local is_mirror = game:GetRoom():IsMirrorWorld()
            local scr_pos = iutils.world_to_screen_ext(dono.Position, is_mirror)

            lost_death_icon:Render(Vector(
                scr_pos.X, scr_pos.Y - config.lost_death_dono_offset
            ))
        end
    end

end

function rems:direction_to_rotation_deg(dir, mirror_x)
    local rot = 0
    mirror_x = mirror_x or false

    if dir == Direction.LEFT then
        rot = mirror_x and 90 or -90
    elseif dir == Direction.RIGHT then
        rot = mirror_x and -90 or 90

    elseif dir == Direction.UP then
        rot = 0
    elseif dir == Direction.DOWN then
        rot = 180
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

    local has_polaroid = iutils.any_player_has_collectible(game, CollectibleType.COLLECTIBLE_POLAROID)
    local has_negative = iutils.any_player_has_collectible(game, CollectibleType.COLLECTIBLE_NEGATIVE)

    -- is level right before cathedral / sheol (including hush) and is a boss room
    if (game_stage == LevelStage.STAGE4_2 or game_stage == LevelStage.STAGE4_3 or game_stage == LevelStage.STAGE5) and
        room:GetType() == RoomType.ROOM_BOSS then
        local OFFSET = Vector(0, 30)

        static_sprites.Color = Color.Default

        if has_polaroid then
            local HEAVEN_DOOR_TYPE = Isaac.GetEntityTypeByName("Heaven Door")
            local HEAVEN_DOOR_VARIANT = Isaac.GetEntityVariantByName("Heaven Door")

            local heaven_doors = Isaac.FindByType(HEAVEN_DOOR_TYPE, HEAVEN_DOOR_VARIANT, 0, true)

            for _, hdoor in ipairs(heaven_doors) do
                local scr_pos = Isaac.WorldToScreen(hdoor.Position)
                render_static_sprite(
                    "ThePolaroid", 0, {
                        pos = scr_pos + OFFSET,
                        scale = Vector(0.8, 0.8)
                    }
                )
            end
        end


        if has_negative then
            local grid_entities = self:get_current_room_grid_entities()

            for _, entity in ipairs(grid_entities) do
                -- is trapdoor?
                if entity:GetType() == GridEntityType.GRID_TRAPDOOR and entity:GetVariant() == 0 then
                    local scr_pos = Isaac.WorldToScreen(entity.Position)

                    render_static_sprite(
                        "TheNegative", 0, {
                            pos = scr_pos + OFFSET,
                            scale = Vector(0.8, 0.8)
                        }
                    )
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
        -- in mirror world, everything in the game is flipped. but sadly
        -- drawing of all sprites from the mod is not, so we have to manually account for that
        local is_mirror = game:GetRoom():IsMirrorWorld()
        local screen_pos = iutils.world_to_screen_ext(door.Position, is_mirror)
        local player = Isaac.GetPlayer()
        local dir = door.Direction
        local rot = self:direction_to_rotation_deg(dir, is_mirror)

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

        -- alt path doors mark
        if door.TargetRoomType == RoomType.ROOM_SECRET_EXIT then
            -- TODO: add animation config for this
            -- disabled for now
            local arrow_count = 1
            local rot_piece = 360 / arrow_count
            
            local time = 0.0

            for i = 0, arrow_count - 1 do
                local animation_scale = math.sin(Isaac.GetTime() * 0.003) * 5
                local animation_offset = Vector(0, -1):Rotated(rot + i * rot_piece + time) * animation_scale -- up vector

                local render_pos = Vector(
                    screen_pos.X, screen_pos.Y
                ) + offset:Rotated(i * rot_piece + time) + animation_offset

                render_static_sprite(
                    "ArrowPivotBottom", 0, {
                        pos = render_pos, rot = rot + (i * rot_piece + time)
                    }
                )
            end
        end

        -- special boss door fool card on special stage
        
        -- TODO: edge case -> gehenna does not have ascent door
        local level = game:GetLevel()
        local is_xl = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0

        if door.TargetRoomType == RoomType.ROOM_BOSS then

            local is_mausoleum_meat_door = door:GetType() == 16 and door:GetVariant() == 3
            local is_ascent_path = game:GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH_INIT) or
                level:IsAscent()

            -- is in mom's floor (possible XL floor edge case)
            -- which in this case would be LevelStage.STAGE3_1 for XL floors
            local should_show_fool_card =
                (level:GetStage() == LevelStage.STAGE3_1 and is_xl) or
                (level:GetStage() == LevelStage.STAGE3_2 and is_xl == false)

            if should_show_fool_card and is_ascent_path == false then
                local has_all_knife_pieces = player:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) and
                    player:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)

                if is_mausoleum_meat_door then
                    if has_all_knife_pieces then
                        local render_pos = Vector(
                            screen_pos.X, screen_pos.Y
                        ) + offset

                        local FULL_MAUSOLEUM_KNIFE_FRAME = 2

                        render_static_sprite(
                            "Knives", FULL_MAUSOLEUM_KNIFE_FRAME, {
                                pos = render_pos, rot = rot
                            }
                        )
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
            if door.TargetRoomType == RoomType.ROOM_CURSE and is_mirror == false and
                ((level:GetStage() == LevelStage.STAGE1_2 and is_xl == false) or (level:GetStage() == LevelStage.STAGE1_1 and is_xl)) and
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
            Isaac.RenderText(tostring(self.extra_info_timer:progress()), 50, 50 + 20, 1, 1, 1, 1)
        end

        self.extra_info_timer:tick_max(self.dt_ms)

    else
        self.extra_info_timer:reset()
    end
end

rems.notify_info_alpha = 0.0

function rems:handle_special_room_notify()
    local lerp_speed = 9.0

    if self.extra_info_timer:progress() < 0.5 then
        self.notify_info_alpha = lerpf(
            self.notify_info_alpha, 0.0, self.dt_ms * lerp_speed
        )
    end
    
    -- boss notify info
    if self.notify_info_timer:max() == false then
        -- only update the timer when time progress
        if game:IsPaused() == false then
            self.notify_info_timer:tick(self.dt_ms)
        end

        if self:get_config().debug_mode then
            Isaac.RenderText(tostring(self.notify_info_timer.span), 50, 50, 1, 1, 1, 1)
        end

    
        -- lock the alpha to 1.0 all the time when in boss notify_info_timer
        self.notify_info_alpha = 1.0
    end

    -- player tab notify info (overrides the fade from the top)
    if self.extra_info_timer:progress() >= 0.5 then
        self.notify_info_alpha = lerpf(
            self.notify_info_alpha, 1.0, self.dt_ms * lerp_speed
        )
    end

    self:render_notify(self.notify_info_alpha)
end

rems.time_progress_anim_pos_offset = Vector(0, 0)
rems.timer_offset_stack = offset_stack.new()

function rems:render_time_progress(offset_stack)
    assert(offset_stack ~= nil, "offset_stack should not be nil")

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

    local lerp_target = Vector.Zero

    local game_time = iutils.get_game_time(game)
    local HIDE_TIME_TOTAL_SECS = 30 * 60

    local should_hide = self.extra_info_timer:max() or
        game_time.total_secs >= HIDE_TIME_TOTAL_SECS


    if should_hide then
        -- TODO HACK: instead of -50, we should calculate the difference between current pos with 0
        lerp_target = Vector(0, -50 - config_offset.Y)
    end

    self.time_progress_anim_pos_offset = lerpv(
        self.time_progress_anim_pos_offset, lerp_target, self.dt_ms * ANIM_SPEED
    )

    local total_offset = config_offset +
        self.time_progress_anim_pos_offset

    local CLOCK_HEIGHT = 20

    clock_sprite.Color   = Color(1, 1, 1, opacity)
    node_tiny.Color      = Color(1, 1, 1, opacity * node_opacity)
    boss_rush_icon.Color = Color(1, 1, 1, opacity)
    hush_icon.Color      = Color(1, 1, 1, opacity)

    local length = w * config.time_progress_width_percent
    local sections = 30 / 5 -- divide in 5 minutes
    local section_len = length / sections

    local SECTION_BODY_HEIGHT = 5

    for i = 0, sections do
        local node_pos = Vector(
            w / 2 - length / 2 + section_len * i + total_offset.X, CLOCK_HEIGHT + total_offset.Y
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

    offset_stack:push_static(
        math.max(CLOCK_HEIGHT + total_offset.Y + SECTION_BODY_HEIGHT, 0)
    )
end

function rems:render_game_timer(offset_stack)
    assert(offset_stack ~= nil, "offsets cannot be nil")
    local config = self:get_config()

    local w = Isaac.GetScreenWidth()
    local game_time = iutils.get_game_time(game)

    local time_str = config.game_timer_subseconds_enabled and string.format(
        "%02.0f:%02.0f:%02.0f.%02.f", game_time.hours, game_time.mins, game_time.secs, game_time.ms
    ) or string.format(
        "%02.0f:%02.0f:%02.0f", game_time.hours, game_time.mins, game_time.secs
    )

    -- TODO: instead we should utilize game_progress's box offset
    local offset = iserializer.decode_vector(self:get_config().game_timer_offset)

    if self.extra_info_timer:max() == false then
        local scale = config.game_timer_scale
        local opacity = config.game_timer_opacity

        Isaac.RenderScaledText(
            time_str,
            w / 2 - Isaac.GetTextWidth(time_str) * scale / 2 + offset.X,
            offset_stack:current() + offset.Y,
            scale, scale,
            0.8, 0.8, 0.8, opacity
        )
    end
end

function rems:render_bum_kill_reminders()
    local level = game:GetLevel()

    local is_bum_killed = level:GetStateFlag(LevelStateFlag.STATE_BUM_KILLED)
    if is_bum_killed == true then
        return
    end
    -- else

    local slots = Isaac.FindByType(EntityType.ENTITY_SLOT, -1, -1, true, false)
    local devil_beggar_var = 5
    local normal_beggar_var = 4
    local battery_bum_var = 13
    local rotten_beggar_var = 18

    local is_mirror = game:GetRoom():IsMirrorWorld()

    for _, slot in ipairs(slots) do
        local ANGEL_DEAL = 0
        local DEVIL_DEAL = 1
        local ALL_DEALS = 2

        local deal_frame = ANGEL_DEAL
        local scr_pos = iutils.world_to_screen_ext(slot.Position, is_mirror)

        local BEGGAR_2_DEAL_FRAME = {
            [devil_beggar_var] = ANGEL_DEAL, [normal_beggar_var] = ALL_DEALS,
            [battery_bum_var] = ALL_DEALS, [rotten_beggar_var] = ALL_DEALS
        }

        local is_deal_affecting_beggar = BEGGAR_2_DEAL_FRAME[slot.Variant] ~= nil

        -- reference https://bindingofisaacrebirth.fandom.com/wiki/Beggar
        if is_deal_affecting_beggar then
            render_static_sprite(
                "Deals", BEGGAR_2_DEAL_FRAME[slot.Variant], {
                    pos = scr_pos, color = Color(1, 1, 1, (math.sin(Isaac.GetTime() * 0.005) + 1) / 2)
                }
            )
        end
    end
end

function rems:render_explosion_immunity_reminder_for_bomb(bomb_entity)
    local is_mirror = game:GetRoom():IsMirrorWorld()

    local scr_pos = iutils.world_to_screen_ext(bomb_entity.Position, is_mirror)
    local opacity = self:get_config().explosion_immunity_reminder_opacity

    local config = self.config
    local size = config.explosion_immunity_reminder_size

    local frame = 0

    if size == enums.Sizes.SIZES_SMALL then
        frame = 0

    elseif size == enums.Sizes.SIZES_MEDIUM then
        frame = 1

    elseif size == enums.Sizes.SIZES_LARGE then
        frame = 2
    end

    render_static_sprite("GreenCircleNoBorder", frame, {
        pos = scr_pos, color = Color(1, 1, 1, opacity)
    })
end

function rems:render_knife_piece_reminders()
    local grid_entities = self:get_current_room_grid_entities()

    local has_knife_piece_1 = iutils.any_player_has_collectible(game, CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
    local has_knife_piece_2 = iutils.any_player_has_collectible(game, CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)

    local KNIFE_PIECE_1_FRAME = 0
    local KNIFE_PIECE_2_FRAME = 1
    local NOTIFY_QUESTION_MARK_FRAME = 1

    local is_mirror = game:GetRoom():IsMirrorWorld()
    local level = game:GetLevel()

    local ANIMATION_TIME_DIFF = 0.5
    local animation_y_offset1 = math.sin(Isaac.GetTime() * 0.001) * 5.5
    local animation_y_offset2 = math.sin(Isaac.GetTime() * 0.001 + ANIMATION_TIME_DIFF) * 5.5
    local GAP = 8

    -- check dross / downpour
    if has_knife_piece_1 == false and level:GetStage() == LevelStage.STAGE1_2 and
    (level:GetStageType() == StageType.STAGETYPE_REPENTANCE or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B) then
        for _, entity in ipairs(grid_entities) do
            -- is trapdoor?
            if entity:GetType() == GridEntityType.GRID_TRAPDOOR and entity:GetVariant() == 0 then
                local scr_pos = iutils.world_to_screen_ext(entity.Position, is_mirror)

                render_static_sprite("Knives", KNIFE_PIECE_1_FRAME, {
                    pos = scr_pos + Vector(-GAP, -20 + animation_y_offset1)
                })

                render_static_sprite("Notify", NOTIFY_QUESTION_MARK_FRAME, {
                    pos = scr_pos + Vector(GAP, -20 + animation_y_offset2)
                })
            end
        end
    end

    -- mines and ashpit
    if has_knife_piece_2 == false and level:GetStage() == LevelStage.STAGE2_2 and
    (level:GetStageType() == StageType.STAGETYPE_REPENTANCE or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B) then
        for _, entity in ipairs(grid_entities) do
            -- is trapdoor?
            if entity:GetType() == GridEntityType.GRID_TRAPDOOR and entity:GetVariant() == 0 then
                local scr_pos = iutils.world_to_screen_ext(entity.Position, is_mirror)

                render_static_sprite("Knives", KNIFE_PIECE_2_FRAME, {
                    pos = scr_pos + Vector(-10, -20 + animation_y_offset1)
                })

                render_static_sprite("Notify", NOTIFY_QUESTION_MARK_FRAME, {
                    pos = scr_pos + Vector(10, -20 + animation_y_offset1)
                })
            end
        end

    end
end

function rems:render_secret_room_placeholders()
    local ROOMS_TO_NOT_SHOW = {
        [RoomType.ROOM_BOSS]            = true,
        [RoomType.ROOM_SUPERSECRET]     = true,
        [RoomType.ROOM_SECRET]          = true,
        [RoomType.ROOM_ERROR]           = true,
        [RoomType.ROOM_DEVIL]           = true,
        [RoomType.ROOM_ANGEL]           = true,
        [RoomType.ROOM_BLACK_MARKET]    = true,
        [RoomType.ROOM_GREED_EXIT]      = true,
        [RoomType.ROOM_SECRET_EXIT]     = true,
        [RoomType.ROOM_TELEPORTER_EXIT] = true,
        [RoomType.ROOM_TELEPORTER]      = true,
        [RoomType.ROOM_DUNGEON]         = true,
        [RoomType.ROOM_BOSSRUSH]        = true,
    }

    local EASY_ROOM_SHAPES = {
        [RoomShape.ROOMSHAPE_1x1] = true,
        [RoomShape.ROOMSHAPE_IH]  = true,
        [RoomShape.ROOMSHAPE_IV]  = true,
        [RoomShape.ROOMSHAPE_IIV] = true,
        [RoomShape.ROOMSHAPE_IIH] = true,
    }

    local config = self:get_config()

    if config.secret_room_placeholder_display_trigger == enums.DisplayTrigger.TRIGGER_EXTRA_INFO
        and self.extra_info_timer:max() == false then
        return
    end

    local room = game:GetRoom()

    if config.secret_room_placeholder_only_clear_rooms_enabled and room:IsClear() == false then
        return
    end

    local is_mirror = room:IsMirrorWorld()
    local room_shape = room:GetRoomShape()
    
    -- crazy long name amirite xD
    if config.secret_room_placeholder_only_hard_to_find_enabled then
        -- early return the easy ones
        if EASY_ROOM_SHAPES[room_shape] ~= nil then
            return
        end
    end

    if ROOMS_TO_NOT_SHOW[room:GetType()] ~= nil then
        return
    end

    for slot=0, DoorSlot.NUM_DOOR_SLOTS do
        if room:IsDoorSlotAllowed(slot) == false then
            goto continue
        end
        local door = room:GetDoor(slot)

        if door ~= nil then
            if door:IsOpen() then
                goto continue
            end
            -- else not open

            -- exception for secret rooms
            if door.TargetRoomType ~= RoomType.ROOM_SECRET and door.TargetRoomType ~= RoomType.ROOM_SUPERSECRET then
                goto continue
            end
        end
        -- else

        local world_pos = room:GetDoorSlotPosition(slot)
        local scr_pos   = iutils.world_to_screen_ext(world_pos, is_mirror)

        local opacity = mapf(
            math.sin(Isaac.GetTime() * 0.001),
            -1, 1, 0.5, 1
        )

        local dir = iutils.doorslot_to_dir(slot)

        secret_room_placeholder.Color    = Color(1, 1, 1, opacity)
        secret_room_placeholder.Rotation = self:direction_to_rotation_deg(dir, is_mirror)
        secret_room_placeholder.Scale    = Vector.One * (1 + math.sin(Isaac.GetTime() * 0.003) * 0.1 + 0.1)

        secret_room_placeholder:SetFrame("Main", 0)
        secret_room_placeholder:Render(scr_pos)

        ::continue::
    end
end

function rems:render_schoolbag_reminder()
    local config = self:get_config()
    local is_mirror = game:GetRoom():IsMirrorWorld()

    -- pedestals are entity pickups
    -- renders for schoolbag
    local pedestals = Isaac.FindByType(EntityType.ENTITY_PICKUP, 100, -1, true)

    local has_active_item_pedestal = false

    for _, pedestal in ipairs(pedestals) do
        if pedestal.SubType == 0 then
            goto continue
        end

        local collectible_conf = Isaac.GetItemConfig():GetCollectible(pedestal.SubType)

        if collectible_conf.Type ~= ItemType.ITEM_ACTIVE then
            goto continue
        end

        has_active_item_pedestal = true

        ::continue::
    end

    if has_active_item_pedestal then
        local player_count = game:GetNumPlayers()
        
        for i = 0, player_count - 1 do
            local player = game:GetPlayer(i)

            if player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG) then
                local offset = Vector(0, config.schoolbag_reminder_yoffset)
                local scr_pos = iutils.world_to_screen_ext(player.Position, is_mirror)

                render_static_sprite(
                    "SchoolbagPivotCenter", 0, {
                        pos = scr_pos + offset
                    }
                )
            end
        end

    end
end

function rems:render_item_reminders()
    -- renders grid
    local cell_size = Vector(16, 16)
    local padding   = Vector(5, 5)
    local offset    = Vector(0, 0)

    local scale     = 1.0

    local items = {}

    local ITEM_ASSOCIATE_REMINDERS = {
        [CollectibleType.COLLECTIBLE_SOCKS] = enums.ItemReminderFrame.IREMINDER_ORPHAN_SOCKS,
    }

    for c, v in pairs(ITEM_ASSOCIATE_REMINDERS) do
        if iutils.any_player_has_collectible(game, c) then
            table.insert(items, v)
        end
    end

    local item_count = #items
    local column_count = 10

    if item_count < column_count then
        column_count = item_count
    end

    local bottom_center = Vector(
        Isaac.GetScreenWidth() * 0.5,
        Isaac.GetScreenHeight()
    )

    local row_count = math.ceil(item_count / column_count)

    for y=0, row_count - 1 do
        local render_count = item_count > column_count and column_count or item_count
        item_count = item_count - render_count

        for x=0, render_count - 1 do

            render_static_sprite(
                "ItemReminders", items[y * row_count + x + 1], {
                    pos = Vector(
                        x * (cell_size.X * scale + padding.X),
                        y * (cell_size.Y * scale + padding.Y)
                    ) + bottom_center
                        + Vector(0, -1) * row_count * (cell_size.Y * scale + padding.Y)
                        + Vector(-1, 0) * column_count * (cell_size.X * scale + padding.X) * 0.5,
                    scale = Vector.One * scale
                }
            )

        end
    end
end

---------------
-- CALLBACKS --
---------------

function rems:on_post_game_started(continued)
    self:log_debug("Game started")

    self.prev_frame_time = Isaac.GetTime()

    if self:HasData() then
        local json_data = self:LoadData()
        self:log_debug(string.format("Loading data: %s", json_data))
        local new_config_data = json.decode(json_data)
        self.config = new_config_data
        self:log_debug(string.format("Data loaded"))
        self:log_debug(string.format("Filling missing data..."))
        configs.clean_config_from_default(self.config)
        self:log_debug(string.format("Data filled."))
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
        self:log_info("MinimapAPI Found.")
        local config = self:get_config()

        if config.map_special_colormarks_enabled then
            self:try_minimap_update_room_color_marks()
        end

        self:log_debug("Updated room marks.")
    else
        self:log_info("MinimapAPI Not Found.")
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

    -- update rooms
    if self:get_config().map_special_colormarks_enabled then
        self:try_minimap_update_room_color_marks()
    end

    self:update_notify_rooms()

    if self:get_config().debug_mode then
        self:log_debug("Updated room marks")
        self:log_debug("Updated notify msg")
    end

    local room = game:GetRoom()

    if MinimapAPI and iutils.is_special_room(room:GetType()) and room:IsMirrorWorld() == false then
        -- are all rooms automatically visited if we go into a new room?
        -- what about special case such as glowing hourglass?
        local room_desc = game:GetLevel():GetCurrentRoomDesc()

        if iutils.room_desc_is_visible(room_desc) then
            MinimapAPI:GetCurrentRoom().Color = iserializer.decode_color(self:get_config().special_color_visited)
        end
    end
end

function rems:on_post_new_floor()
    self:log_debug("new floor entered, cleared all marks")

    if self:get_config().map_special_colormarks_enabled then
        self:try_minimap_update_room_color_marks()
    end

    self:log_debug("Updated Room marks")
end

function rems:on_pre_spawn_clean_award(_rng)
    -- recommended by discord users: shows a big arrow and add audio cues
    self:update_notify_rooms()

    if self:get_config().map_special_colormarks_enabled then
        self:try_minimap_update_room_color_marks()
    end

    local current_room = game:GetRoom()

    if current_room ~= nil and current_room:GetType() == RoomType.ROOM_BOSS then
        self:on_boss_completed(current_room)
    end
end

function rems:on_boss_completed(boss_room)
    self:log_debug("BOSS COMPLETED, NOTIFY PLAYER ABOUT MISSED SPECIAL ROOMS")

    -- TODO: handle mirror floors differently, although Im still unsure on how to
    -- Check whether or not it has been seen in the normal world
    local level = game:GetLevel()

    if level:GetStage() ~= LevelStage.STAGE7 then
        self:start_notify_info()
    end
end


function rems:on_post_render()
    local MS2SECS = 1 / 1000
    self.dt_ms = (Isaac.GetTime() - self.prev_frame_time) * MS2SECS

    local config = self:get_config()

    if game:GetHUD():IsVisible() and ModConfigMenu.IsVisible == false then
        self:handle_extra_info_timer()

        -- in game
        if config.door_reminders_enabled then
            self:render_door_reminders()
        end

        if config.lost_death_icon_enabled then
            self:render_lost_death_icon()
        end

        self.timer_offset_stack:clear()

        if config.knife_piece_reminders_enabled then
            self:render_knife_piece_reminders()
        end

        -- BUM KILL REMINDERS :O (shocking ikr)
        -- Greed mode has no effect even if we killed any bummies :)
        -- thats just mass genocide amirite
        local stage = game:GetLevel():GetStage()
        -- Maybe consider STAGE_NULL??
        local first_stage = LevelStage.STAGE1_1

        local is_greed = game:IsGreedMode()

        if config.bum_kill_reminders_enabled and is_greed == false and stage ~= first_stage then
            self:render_bum_kill_reminders()
        end

        if config.secret_room_placeholder_enabled then
            self:render_secret_room_placeholders()
        end

        -- UI, should be drawn as an overlay
        if config.notify_info_enabled then
            self:handle_special_room_notify()
        end


        if config.time_progress_enabled then
            if config.time_progress_disable_in_greed and is_greed == false then
                self:render_time_progress(self.timer_offset_stack)
            end

            if config.time_progress_disable_in_greed == false then
                self:render_time_progress(self.timer_offset_stack)
            end
        end

        if config.game_timer_enabled then
            self:render_game_timer(self.timer_offset_stack)
        end

        -- incomplete
        -- self:render_item_reminders()
    end

    self.prev_frame_time = Isaac.GetTime()
end

function rems:on_post_player_render(player, render_offset)
    local config = self:get_config()
    if config.schoolbag_reminder_enabled then
        self:render_schoolbag_reminder()
    end
end

function rems:on_post_bomb_render(bomb_entity, _)
    local config = self:get_config()
    if config.explosion_immunity_reminders_enabled == false then
        return
    end


    local has_explosive_immunity = iutils.player_any_of(game,
        function(player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) or
                player:HasCollectible(CollectibleType.COLLECTIBLE_HOST_HAT)
        end
    )

    if not has_explosive_immunity then
        return
    end
    -- else

    self:render_explosion_immunity_reminder_for_bomb(bomb_entity)
end

rems.near_death_shader_strength = 0.0

function rems:get_shader_params(shader_name)
    local config = self:get_config()

    local circle_shader_name = "near_death_vignette_circle"
    local surround_shader_name = "near_death_vignette_surround"

    local disable_params = { Time = 0, Strength = 0.0, Opacity = 0.0 }

    if shader_name == circle_shader_name and
        config.near_death_effect_shader_type ~= enums.NearDeathEffectShader.EFFECT_SHADER_CIRCLE then
        return disable_params 
    end

    if shader_name == surround_shader_name and
        config.near_death_effect_shader_type ~= enums.NearDeathEffectShader.EFFECT_SHADER_SURROUND then
        return disable_params 
    end

    if shader_name == circle_shader_name or shader_name == surround_shader_name then
        local main_player = Isaac.GetPlayer()

        local total_hit_units = iutils.get_total_hit_units(main_player)
        
        -- holy mantle, wooden cross, blanket are all considered holy mantle effects
        local mantle_count = iutils.get_total_mantle_effect_count(main_player)

        local is_lost_or_tlost = main_player:GetPlayerType() == PlayerType.PLAYER_THELOST or
            main_player:GetPlayerType() == PlayerType.PLAYER_THELOST_B

        local is_near_death = (total_hit_units + mantle_count) <= config.near_death_effect_hit_units_threshold

        
        -- special case for lost and tlost
        if is_lost_or_tlost then
            is_near_death = mantle_count == 0
        end

        local is_curse_of_unknown = game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= 0

        local target_strength = 0.0

        if config.near_death_effect_enabled then

            -- should bypass curse of the unknown or not
            if config.near_death_effect_bypass_COTU and is_near_death then
                target_strength = config.near_death_effect_strength

            elseif is_near_death and not is_curse_of_unknown then
                target_strength = config.near_death_effect_strength
            end

        end

        local lerp_speed = 2.5

        self.near_death_shader_strength = lerpf(
            self.near_death_shader_strength, target_strength, self.dt_ms * lerp_speed
        )

        local params = {
            Time = Isaac.GetFrameCount(),
            Strength = self.near_death_shader_strength,
            Opacity = config.near_death_effect_opacity,
        }

        return params
    end
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
rems:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, rems.on_post_player_render)

rems:AddCallback(ModCallbacks.MC_EXECUTE_CMD, rems.on_execute_cmd)

rems:AddCallback(ModCallbacks.MC_POST_BOMB_RENDER, rems.on_post_bomb_render)
rems:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, rems.get_shader_params)

