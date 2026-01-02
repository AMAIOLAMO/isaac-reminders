-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

local enums = {
    AnchorType = {
        ANCHOR_BEGIN = 0,

        -- LSB indicates vertical alignment
        ANCHOR_TOP    = 1 << 0,
        ANCHOR_BOTTOM = 0 << 0,

        -- second significant bit represents horizontal alignment
        ANCHOR_LEFT  = 1 << 1,
        ANCHOR_RIGHT = 0 << 1,

        ANCHOR_END = (1 << 0) | (1 << 1) -- 0b11
    },
    NotifyInfoType = {
        NOTIFY_BEGIN     = 1,
        NOTIFY_ICON      = 1,
        NOTIFY_TEXT      = 2,
        NOTIFY_ICON_TEXT = 3,
        NOTIFY_END       = 3
    },

    Sizes = {
        SIZES_BEGIN  = 1,
        SIZES_SMALL  = 1,
        SIZES_MEDIUM = 2,
        SIZES_LARGE  = 3,
        SIZES_END    = 3,
    },

    DisplayTrigger = {
        TRIGGER_BEGIN      = 1,
        TRIGGER_ALWAYS     = 1,
        TRIGGER_EXTRA_INFO = 2,
        TRIGGER_END        = 2,
    },

    NearDeathEffectShader = {
        EFFECT_SHADER_BEGIN    = 1,
        EFFECT_SHADER_CIRCLE   = 1,
        EFFECT_SHADER_SURROUND = 2,
        EFFECT_SHADER_END      = 2,
    },

    ItemReminderFrame = {
        IREMINDER_SCHOOLBAG    = 0,
        IREMINDER_ORPHAN_SOCKS = 1,
    },

    FloorType = {
        STAGE_BEGIN           = 1 << 0,

        STAGE_BASEMENT        = 1 << 0,
        STAGE_CELLAR          = 1 << 1,
        STAGE_BURNING_BASEMENT= 1 << 2,
        STAGE_DOWNPOUR        = 1 << 3,
        STAGE_DROSS           = 1 << 4,

        STAGE_CAVES           = 1 << 5,
        STAGE_CATACOMBS       = 1 << 6,
        STAGE_FLOODED_CAVES   = 1 << 7,
        STAGE_MINES           = 1 << 8,
        STAGE_ASHPIT          = 1 << 9,

        STAGE_DEPTHS          = 1 << 10,
        STAGE_NECROPOLIS      = 1 << 11,
        STAGE_DANK_DEPTHS     = 1 << 12,
        STAGE_MAUSOLEUM       = 1 << 13,
        STAGE_GEHENNA         = 1 << 14,

        STAGE_WOMB            = 1 << 15,
        STAGE_UTERO           = 1 << 16,
        STAGE_SCARRED_WOMB    = 1 << 17,
        STAGE_CORPSE          = 1 << 18,

        STAGE_HUSH            = 1 << 19,

        STAGE_SHEOL           = 1 << 20,
        STAGE_CATHEDRAL       = 1 << 21,

        STAGE_DARK_ROOM       = 1 << 22,
        STAGE_CHEST           = 1 << 23,

        STAGE_VOID            = 1 << 24,

        STAGE_HOME            = 1 << 25,

        STAGE_END             = 1 << 25,
    },

    -- FloorType = {
    --     STAGE_BASEMENT = 1 << 0, STAGE_CELLAR = 1 << 1, STAGE_BURNING_BASEMENT, STAGE_DOWNPOUR, STAGE_DROSS,
    --     STAGE_CAVES, STAGE_CATACOMBS, STAGE_FLOODED_CAVES, STAGE_MINES, STAGE_ASHPIT,
    --     STAGE_DEPTHS, STAGE_NECROPOLIS, STAGE_DANK_DEPTHS, STAGE_MAUSOLEUM, STAGE_GEHENNA,
    --     STAGE_WOMB, STAGE_UTERO, STAGE_SCARRED_WOMB, STAGE_CORPSE,
    --     STAGE_HUSH,
    --     STAGE_SHEOL, STAGE_CATHEDRAL, STAGE_DARK_ROOM, STAGE_CHEST, STAGE_VOID, STAGE_HOME
    -- },

    LanguageString = {
    }
}

function enums.NotifyInfoType:to_description(type)
    if type == self.NOTIFY_ICON_TEXT then
        return "Notify Icon and Text"

    elseif type == self.NOTIFY_ICON then
        return "Notify Icon Only"

    elseif type == self.NOTIFY_TEXT then
        return "Notify Text Only"
    end

    assert(false, "unexpected type")
end

function enums.Sizes:to_description(type)
    if type == self.SIZES_SMALL then
        return "Small"

    elseif type == self.SIZES_MEDIUM then
        return "Medium"

    elseif type == self.SIZES_LARGE then
        return "Large"
    end

    assert(false, "unexpected type")
end

function enums.DisplayTrigger:to_description(type)
    if type == self.TRIGGER_ALWAYS then
        return "Always"

    elseif type == self.TRIGGER_EXTRA_INFO then
        return "On Extra Info"
    end

    assert(false, "unexpected type")
end

function enums.NearDeathEffectShader:to_description(type)
    if type == self.EFFECT_SHADER_CIRCLE then
        return "Circle"

    elseif type == self.EFFECT_SHADER_SURROUND then
        return "Surround"
    end

    assert(false, "unexpected type")
end

return enums
