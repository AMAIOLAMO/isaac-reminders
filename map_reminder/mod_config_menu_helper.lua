local ModConfigMenuHelper = {}

function ModConfigMenuHelper.AddColorSetting(mod_name, category, args)
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
