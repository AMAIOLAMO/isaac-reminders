-- AUTHOR: CxRedix
-- TODO:
-- 1. add alt path reminders (partially done)
-- 2. icons
-- 3. put this on github

local MOD_NAME = "Map Reminder"
local map_rem = RegisterMod(MOD_NAME, 1)

local json = require("map_reminder.lib.json")
local timerf = require("map_reminder.timerf")
local iserializer = require("map_reminder.iserializer")
local config_menu_helper = require("map_reminder.mod_config_menu_helper")

local notify_sprite = Sprite()
notify_sprite:Load("gfx/notify.anm2", true)

local alt_arrow = Sprite()
alt_arrow:Load("gfx/alt_arrow.anm2", true)

local game = Game()

map_rem.marked_rooms = {}

function map_rem.get_default_config()
    return {
        special_color_unvisited = iserializer.encode_color(Color(1, 0, 0)),
        special_color_visited = iserializer.encode_color(Color(0, 1, 0)),
        normal_color_marked = iserializer.encode_color(Color(1, 1, 0)),
        debug_mode = true,
        notify_text_header = "=== ![Map Reminder]! ===",
        notify_msg_offset = iserializer.encode_vector(Vector(0, 0)),
        icon_scale = 1.5,
    }
end

map_rem.config = map_rem.get_default_config()

map_rem.map_call_timer = timerf.new(0.5, 0)

map_rem.notify_special_rooms = {}
map_rem.notify_msg = ""
map_rem.notify_msg_timer = timerf.new(5, 5)
map_rem.notify_msg_start_fade = 4

map_rem.alt_path_arrow_doors = {
    [RoomType.ROOM_SECRET_EXIT] = true
}

-- Room names
-- TODO: maybe support translation?
map_rem.notify_room_names = {
    [RoomType.ROOM_SECRET] = "Secret Room",
    [RoomType.ROOM_SUPERSECRET] = "Super Secret Room",
    [RoomType.ROOM_ULTRASECRET] = "Ultra Secret Room",

    [RoomType.ROOM_SHOP] = "Shop",
    [RoomType.ROOM_TREASURE] = "Treasure Room",
    [RoomType.ROOM_SACRIFICE] = "Sacrifice Room",
    [RoomType.ROOM_LIBRARY] = "Library",
    [RoomType.ROOM_ARCADE] = "Arcade",
    [RoomType.ROOM_CHALLENGE] = "Challenge Room",

    [RoomType.ROOM_ISAACS] = "Bedroom",
    [RoomType.ROOM_BARREN] = "Barren Bedroom",

    [RoomType.ROOM_CHEST] = "Chest Room",
    [RoomType.ROOM_DICE] = "Dice Room",
    [RoomType.ROOM_PLANETARIUM] = "Planetarium",
    [RoomType.ROOM_CURSE] = "Curse Room",
    [RoomType.ROOM_MINIBOSS] = "Miniboss Room",

    [RoomType.ROOM_DEVIL] = "Devil Room",
    [RoomType.ROOM_ANGEL] = "Angel Room",

    [RoomType.ROOM_BOSS] = "Boss Room",
}

if MinimapAPI then
    map_rem.minimapapi_icons = Sprite()
    map_rem.minimapapi_icons:Load("gfx/ui/minimapapi_icons.anm2", true)

    map_rem.minimapapi_roomtype2icon = {
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

map_rem.dt_ms = 0
map_rem.prev_frame_time = 0.0

-- simple implementation of shallow copy
function table.shallow_copy(tbl)
  local new_tbl = {}

  for k,v in pairs(tbl) do
    new_tbl[k] = v
  end

  return new_tbl
end


function map_rem:log_debug(msg)
    if map_rem:get_config().debug_mode then
        print(string.format("[DBG][%s][%s]: %s", MOD_NAME, tostring(Isaac.GetTime()), msg))
    end
end

function map_rem:log_info(msg)
    print(string.format("[INFO][%s][%s]: %s", MOD_NAME, tostring(Isaac.GetTime()), msg))
end

-- lazy load config
function map_rem:get_config()
    assert(map_rem.config, "config is nil")
    return map_rem.config
end

function map_rem:start_notify_msg(msg)
    self.notify_msg = msg
    self.notify_msg_timer:reset()
end

function map_rem:refresh_notify_msg_timer()
    self.notify_msg_timer:reset()
end

function map_rem:mark_room(room)
    self.marked_rooms[room.Position] = {
        pos = room.Position,
        original_color = room.Color
    }

    room.Color = iserializer.decode_color(map_rem:get_config().normal_color_marked)
end

function map_rem:unmark_room(room)
    room.Color = self.marked_rooms[room.Position].original_color
    self.marked_rooms[room.Position] = nil
end

function map_rem:is_room_marked(room)
    return self.marked_rooms[room.Position] ~= nil
end

function map_rem:is_any_secret_room(room)
    return room.Descriptor and
        (room.Type == RoomType.ROOM_SECRET or
        room.Type == RoomType.ROOM_SUPERSECRET or
        room.Type == RoomType.ROOM_ULTRASECRET)
end

function map_rem:is_normal_room(room)
    return room.Descriptor and room.Type == RoomType.ROOM_DEFAULT
end

function map_rem:is_special_room(room)
    return room.Descriptor and
        room.Type ~= RoomType.ROOM_NULL and not map_rem:is_normal_room(room)
end

function map_rem:update_room_marks()
    local special_rooms = {}

    for _, room in ipairs(MinimapAPI:GetLevel()) do
        if map_rem:is_special_room(room) then
            table.insert(special_rooms, room)
            -- probably make this customizable?
            local room_visit_count = room.Descriptor.VisitedCount

            local config = map_rem:get_config()

            -- Special Case for Miniboss (as it is an ambush >:D) 
            if room.Type == RoomType.ROOM_MINIBOSS then
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

    map_rem:log_debug(output_str)
end

function map_rem:get_unvisited_special_rooms()
    assert(MinimapAPI, "Cannot find MinimapAPI!")
    local rooms = {}
    
    for _, room in ipairs(MinimapAPI:GetLevel()) do
        if map_rem:is_special_room(room) and room:IsVisited() == false then
            table.insert(rooms, room)
        end
    end

    return rooms
end

function map_rem:update_notify_rooms()
    local unvisited_special_rooms = self:get_unvisited_special_rooms()

    for _, room in ipairs(unvisited_special_rooms) do
        local desc = room.Descriptor

        local room_name = self.notify_room_names[room.Type]

        -- Curse of the lost will not affect the display flags
        local should_notify = (room:IsVisible() and room:IsIconVisible()) or self:is_any_secret_room(room)

        if room_name ~= nil and should_notify then
            table.insert(self.notify_special_rooms, {
                type = room.Type,
                name = room_name
            })
            -- notify_msg = string.format("%s\n--> %s", notify_msg, room_name)
        end

    end

    self:log_debug("Notify rooms updated")
end

function map_rem:get_notify_msg_with_unvisited_special_rooms()
    local notify_msg = map_rem.get_config().notify_text_header

    local unvisited_special_rooms = map_rem:get_unvisited_special_rooms()

    for _, room in ipairs(unvisited_special_rooms) do
        local desc = room.Descriptor

        local room_name = map_rem.notify_room_names[room.Type]

        if map_rem:get_config().debug_mode then
            notify_msg = string.format("%s\n--> room_name: %s, display_flags: %d", notify_msg, room_name or "NIL", room:GetDisplayFlags())
        else
            -- Curse of the lost will not affect the display flags
            local should_notify = (room:IsVisible() and room:IsIconVisible()) or map_rem:is_any_secret_room(room)

            if room_name ~= nil and should_notify then
                notify_msg = string.format("%s\n--> %s", notify_msg, room_name)
            end
        end

    end

    return notify_msg
end

function map_rem:notify_unvisited_special_rooms()
    local msg = self:get_notify_msg_with_unvisited_special_rooms()
    map_rem:update_notify_rooms()

    self:start_notify_msg(msg)
end

-- CALLBACKS --

function map_rem.on_post_game_started()
    map_rem:log_debug("Game started")

    map_rem.prev_frame_time = Isaac.GetTime()

    -- should load
    if MinimapAPI then
        map_rem:log_info("Minimap Found.")
        map_rem:update_room_marks()
        map_rem:log_debug("Updated rooms")

        if map_rem.minimapapi_icons and map_rem.minimapapi_icons:IsLoaded() then
            map_rem:log_info("Minimapapi icons loaded")
        end
    else
        map_rem:log_info("Minimap Not Found.")
    end
end

function map_rem:on_pre_game_exit()
    -- should save
    assert(map_rem:get_config(), "Cannot save data because config is nil")
    local json_data = json.encode(map_rem:get_config())
    map_rem:log_debug(string.format("Saving data: %s", json_data))
    map_rem:SaveData(json_data)
end

function map_rem.on_execute_cmd(_, command, args)
    if command == "MR_reset" then
        map_rem:log_debug("resetting...")
        
        return "Reset data complete"
    end
    
end

function map_rem.on_post_new_room()
    if not MinimapAPI then
        return
    end
    -- else
    
    -- update rooms
    map_rem:update_room_marks()
    map_rem:update_notify_rooms()
    map_rem.notify_msg = map_rem:get_notify_msg_with_unvisited_special_rooms()

    if map_rem:get_config().debug_mode then
        map_rem:log_debug("Updated room marks")
        map_rem:log_debug("Updated notify msg")


        -- TODO: check white fire for the entire floor and show icon above curse room
        local white_fire_variant = 4
        local white_fires = Isaac.FindByType(EntityType.ENTITY_FIREPLACE, white_fire_variant)
        
        if white_fires then
            for _, white_fire in ipairs(white_fires) do
                map_rem:log_debug("Found white fire at location: <%.2f, %.2f>", white_fire.Position.X, white_fire.Position.Y)
            end
        end
    end

    local new_room = MinimapAPI:GetCurrentRoom()
    assert(new_room, "minimapapi returned new room is nil")

    if map_rem:is_special_room(new_room) then
        -- are all rooms automatically visited if we go into a new room?
        -- what about special case such as glowing hourglass?
        if new_room:IsVisited() then
            new_room.Color = iserializer.decode_color(map_rem:get_config().special_color_visited)
        end
    end
end

function map_rem.on_post_new_floor()
    if not MinimapAPI then
        return
    end
    -- else
    
    -- clear entries on new floor
    local marked_rooms_size = #map_rem.marked_rooms
    for k, v in ipairs(map_rem.marked_rooms) do
        map_rem.marked_rooms[k] = nil
    end

    map_rem:log_debug("new floor entered, cleared all marks")

    map_rem:update_room_marks()

    map_rem:log_debug("Updated Room marks")
end

function map_rem.on_pre_spawn_clean_award(_rng)
    if not MinimapAPI then
        return
    end
    -- else

    -- TODO: alt floor reminders
    -- when room completes, we check if the room contains alt floor doors
    -- recommended by discord users: shows a big arrow and add audio cues

    map_rem:update_notify_rooms()
    map_rem.notify_msg = map_rem:get_notify_msg_with_unvisited_special_rooms()

    local current_room = MinimapAPI:GetCurrentRoom()

    -- TODO: Handle void floor differently, as it could be annoying to show up everytime
    -- TODO: handle mirror floors differently, although Im still unsure on how to
    -- Check whether or not it has been seen in the normal world
    if current_room.Descriptor and current_room.Type == RoomType.ROOM_BOSS then
        map_rem:on_boss_completed(current_room)
    end
end

function map_rem.on_boss_completed(self, boss_room)
    if not MinimapAPI then
        return
    end

    map_rem:log_debug("BOSS COMPLETED, NOTIFY PLAYER ABOUT MISSED SPECIAL ROOMS")

    map_rem:notify_unvisited_special_rooms()
end

function map_rem:render_room_icon(room_type, pos)
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
function map_rem:render_notify(alpha)
    local width = Isaac.GetScreenWidth()
    local text_width = Isaac.GetTextWidth(self:get_config().notify_text_header)

    local offset = iserializer.decode_vector(self:get_config().notify_msg_offset)

    notify_sprite:SetFrame(notify_sprite:GetDefaultAnimation(), 0)
    notify_sprite:Render(Vector(
        (width - text_width) / 2 - 32 + offset.X, 50 + offset.Y
    ))

    Isaac.RenderText(self.notify_msg, (width - text_width) / 2 + offset.X, 50 + offset.Y, 1, 1, 1, alpha)
end

function map_rem.on_post_render()
    local MS2SECS = 1 / 1000
    map_rem.dt_ms = (Isaac.GetTime() - map_rem.prev_frame_time) * MS2SECS

    if not MinimapAPI then
        return
    end

    -- debug doors
    local room = game:GetRoom()
    local doors = {}

    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door then
            table.insert(doors, door)
        end
    end

    for _, door in ipairs(doors) do
        local screen_pos = Isaac.WorldToScreen(door.Position)
        if map_rem:get_config().debug_mode then
            Isaac.RenderText(
                string.format("%d.%d\n<%.2f, %.2f>\nState: %d\nVarData: %d\nRoomType: %d", door:GetType(), door:GetVariant(), door.Position.X, door.Position.Y, door.State, door.VarData, door.TargetRoomType),
                screen_pos.X, screen_pos.Y, 1, 1, 1, 1
            )
        end

        if map_rem.alt_path_arrow_doors[door.TargetRoomType] ~= nil then
            alt_arrow:Play("Idle")
            alt_arrow:Update()
            local render_arrow_pos = Vector(
                screen_pos.X, screen_pos.Y - 20
            )
            alt_arrow:Render(render_arrow_pos)
        end
    end




    if map_rem.notify_msg_timer:max() == false then
        -- only update the timer when time progress
        if game:IsPaused() == false then
            map_rem.notify_msg_timer:tick(map_rem.dt_ms)
        end

        if map_rem:get_config().debug_mode then
            Isaac.RenderText(tostring(map_rem.notify_msg_timer.span), 50, 50, 1, 1, 1, 1)
        end

        local alpha = 1

        if map_rem.notify_msg_start_fade < map_rem.notify_msg_timer.span then
            local fade_progress = (map_rem.notify_msg_timer.span - map_rem.notify_msg_start_fade) /
                (map_rem.notify_msg_timer.max_span - map_rem.notify_msg_start_fade)

            alpha = 1 - fade_progress
        end
    
        map_rem:render_notify(alpha)
    end

    local main_player = Isaac.GetPlayer()

    if Input.GetActionValue(ButtonAction.ACTION_MAP, main_player.ControllerIndex) >= 0.5 then
        if map_rem:get_config().debug_mode then
            Isaac.RenderText(tostring(map_rem.map_call_timer.span), 50, 50, 1, 1, 1, 1)
        end

        if map_rem.map_call_timer:tick_max(map_rem.dt_ms) then
            map_rem:render_notify(1.0)
        end
    else
        map_rem.map_call_timer:reset()
    end

    -- KEYBOARD SPECIFIC CONTROLS --
    -- TODO: add remapping ability utilizing Mod Config Menu
    if Input.IsButtonTriggered(Keyboard.KEY_G, 0) then
        map_rem:notify_unvisited_special_rooms()
    end

    if Input.IsButtonTriggered(Keyboard.KEY_N, 0) then
        map_rem:log_debug("N pressed, toggle marking of room")
        local current_room = MinimapAPI:GetCurrentRoom()

        if map_rem:is_room_marked(current_room) then
            map_rem:unmark_room(current_room)
            map_rem:log_debug("room unmarked")
        else
            map_rem:mark_room(current_room)
            map_rem:log_debug("room marked")
        end
    end


    map_rem.prev_frame_time = Isaac.GetTime()
end

-- MOD CONFIG MENU SUPPORT --

-- SIMPLIFY MOD CONFIG MENU FOR common settings.
if ModConfigMenu then
    -- GENERAL SECTION --
    ModConfigMenu.AddText(MOD_NAME, "General", "Developer")

    ModConfigMenu.AddSetting(
        MOD_NAME, "General", {
            Type = ModConfigMenu.OptionType.BOOLEAN,

            CurrentSetting = function()
                return map_rem:get_config().debug_mode
            end,

            Display = function()
                return "Debug Mode: " .. (map_rem:get_config().debug_mode and "on" or "off")
            end,

            OnChange = function(value)
                map_rem:get_config().debug_mode = value
            end,

            Info = { -- This can also be a function instead of a table
                "debug mode displays extra information",
                "in debug console / while using the mod"
            }
        }
    )
    
    -- VISUALS SECTION -- 
    ModConfigMenu.AddText(MOD_NAME, "Visuals", "Notify Message")
    ModConfigMenu.AddSetting(
        MOD_NAME, "Visuals", {
            Type = ModConfigMenu.OptionType.NUMBER,

            CurrentSetting = function()
                return map_rem:get_config().notify_msg_offset[1]
            end,

            Display = function()
                return "Offset X: " .. tostring(map_rem:get_config().notify_msg_offset[1])
            end,

            Minimum = -500, Maximum = 500,

            OnChange = function(value)
                map_rem:get_config().notify_msg_offset[1] = value
            end,

            Info = { -- This can also be a function instead of a table
                "Changes the x offset of the map reminder message at the end of each boss",
            }
        }
    )
    ModConfigMenu.AddSetting(
        MOD_NAME, "Visuals", {
            Type = ModConfigMenu.OptionType.NUMBER,

            CurrentSetting = function()
                return map_rem:get_config().notify_msg_offset[2]
            end,

            Display = function()
                return "Offset Y: " .. tostring(map_rem:get_config().notify_msg_offset[2])
            end,

            Minimum = -500, Maximum = 500,

            OnChange = function(value)
                map_rem:get_config().notify_msg_offset[2] = value
            end,

            Info = { -- This can also be a function instead of a table
                "Changes the y offset of the map reminder message at the end of each boss",
            }
        }
    )

    ModConfigMenu.AddText(MOD_NAME, "Visuals", "Unvisited Rooms")
    config_menu_helper.AddColorSetting(
        MOD_NAME, "Visuals", {
            CurrentSetting = function()
                return iserializer.decode_color(map_rem:get_config().special_color_unvisited)
            end,

            OnChange = function(new_color)
                map_rem:get_config().special_color_unvisited = iserializer.encode_color(new_color)
            end
        }
    )

    ModConfigMenu.AddText(MOD_NAME, "Visuals", "Visited Rooms")
    config_menu_helper.AddColorSetting(
        MOD_NAME, "Visuals", {
            CurrentSetting = function()
                return iserializer.decode_color(map_rem:get_config().special_color_visited)
            end,

            OnChange = function(new_color)
                map_rem:get_config().special_color_visited = iserializer.encode_color(new_color)
            end
        }
    )
end


-- Callback Registers --
map_rem:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, map_rem.on_post_game_started)
map_rem:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, map_rem.on_pre_game_exit)

map_rem:AddCallback(ModCallbacks.MC_POST_RENDER, map_rem.on_post_render)
map_rem:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, map_rem.on_post_new_room)
map_rem:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, map_rem.on_post_new_floor)
map_rem:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, map_rem.on_pre_spawn_clean_award)

map_rem:AddCallback(ModCallbacks.MC_EXECUTE_CMD, map_rem.on_execute_cmd)
