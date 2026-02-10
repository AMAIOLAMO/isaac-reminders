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
        FLOOR_BEGIN           = 1 << 0,

        FLOOR_BASEMENT        = 1 << 0,
        FLOOR_CELLAR          = 1 << 1,
        FLOOR_BURNING_BASEMENT= 1 << 2,
        FLOOR_DOWNPOUR        = 1 << 3,
        FLOOR_DROSS           = 1 << 4,

        FLOOR_CAVES           = 1 << 5,
        FLOOR_CATACOMBS       = 1 << 6,
        FLOOR_FLOODED_CAVES   = 1 << 7,
        FLOOR_MINES           = 1 << 8,
        FLOOR_ASHPIT          = 1 << 9,

        FLOOR_DEPTHS          = 1 << 10,
        FLOOR_NECROPOLIS      = 1 << 11,
        FLOOR_DANK_DEPTHS     = 1 << 12,
        FLOOR_MAUSOLEUM       = 1 << 13,
        FLOOR_GEHENNA         = 1 << 14,

        FLOOR_WOMB            = 1 << 15,
        FLOOR_UTERO           = 1 << 16,
        FLOOR_SCARRED_WOMB    = 1 << 17,
        FLOOR_CORPSE          = 1 << 18,

        FLOOR_HUSH            = 1 << 19,

        FLOOR_SHEOL           = 1 << 20,
        FLOOR_CATHEDRAL       = 1 << 21,

        FLOOR_DARK_ROOM       = 1 << 22,
        FLOOR_CHEST           = 1 << 23,

        FLOOR_VOID            = 1 << 24,

        FLOOR_HOME            = 1 << 25,

        FLOOR_NULL            = 1 << 26,

        FLOOR_END             = 1 << 26
    },
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
