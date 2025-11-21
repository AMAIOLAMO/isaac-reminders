-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix
local ModConfigMenuHelper = {}

function ModConfigMenuHelper.add_vector_setting(mod_name, category, args)
    local MCM = ModConfigMenu
    assert(MCM, "Cannot find mod config menu!")

    MCM.AddSetting(
        mod_name, category, {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return args.CurrentSetting().X
            end,

            Display = function()
                return "Offset X: " .. tostring(args.CurrentSetting().X)
            end,

            Minimum = -500, Maximum = 500,

            OnChange = function(value)
                args.OnChange(
                    Vector(value, args.CurrentSetting().Y)
                )
            end,

            Info = {
                "The X axis offset"
            }
        }
    )

    MCM.AddSetting(
        mod_name, category, {
            Type = MCM.OptionType.NUMBER,

            CurrentSetting = function()
                return args.CurrentSetting().Y
            end,

            Display = function()
                return "Offset Y: " .. tostring(args.CurrentSetting().Y)
            end,

            Minimum = -500, Maximum = 500,

            OnChange = function(value)
                args.OnChange(
                    Vector(args.CurrentSetting().X, value)
                )
            end,

            Info = {
                "The y axis offset"
            }
        }
    )
end

function ModConfigMenuHelper.add_color_setting(mod_name, category, args)
    ModConfigMenu.AddSetting(
        mod_name, category, {
            Type = ModConfigMenu.OptionType.NUMBER,

            CurrentSetting = function()
                return args.CurrentSetting().R * 255
            end,

            Minimum = 0, Maximum = 255,

            Display = function()
                return "Color Red: " .. tostring(math.floor(args.CurrentSetting().R * 255))
            end,


            OnChange = function(value)
                local new_color = args.CurrentSetting()
                new_color.R = value / 255

                args.OnChange(new_color)
            end,

            Info = {
                "the red color",
            }
        }
    )

    ModConfigMenu.AddSetting(
        mod_name, category, {
            Type = ModConfigMenu.OptionType.NUMBER,

            CurrentSetting = function()
                return args.CurrentSetting().G * 255
            end,

            Minimum = 0, Maximum = 255,

            Display = function()
                return "Color Green: " .. tostring(math.floor(args.CurrentSetting().G * 255))
            end,


            OnChange = function(value)
                local new_color = args.CurrentSetting()
                new_color.G = value / 255

                args.OnChange(new_color)
            end,

            Info = {
                "the green color",
            }
        }
    )

    ModConfigMenu.AddSetting(
        mod_name, category, {
            Type = ModConfigMenu.OptionType.NUMBER,

            CurrentSetting = function()
                return args.CurrentSetting().B * 255
            end,

            Minimum = 0, Maximum = 255,

            Display = function()
                return "Color Blue: " .. tostring(math.floor(args.CurrentSetting().B * 255))
            end,


            OnChange = function(value)
                local new_color = args.CurrentSetting()
                new_color.B = value / 255

                args.OnChange(new_color)
            end,

            Info = {
                "the blue color",
            }
        }
    )
end

return ModConfigMenuHelper
