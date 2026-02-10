-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

local lang = include("reminders.language")
local LE = include("reminders.language_enum")
local Languages = {}

Languages.English = lang.new({
    [LE.LNOTIFY_TEXT_HEADER     ] = "=== ![Missed Special Rooms]! === ",
    [LE.LNOTIFY_TEXT_HEADER_OK  ] = "No Missed Special Rooms :)",
    [LE.LNOTIFY_TEXT_HEADER_LOST] = "Oh no! You have Curse of The Lost :(",
})

Languages.Chinese = lang.new({

})

Languages.Russian = lang.new({

})


return Languages
