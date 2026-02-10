-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

local Language = {}
Language.__index = Language

function Language.new(lang_table)
    return setmetatable(
        { lang_table = lang_table }, Language
    )
end

function Language:get(key)
    assert(self.lang_table[key] ~= nil, tostring(key) .. " does not exist as a key for the translation table: " .. tostring(self.lang_table))
    return self.lang_table[key]
end

function Language:has(key)
    return self.lang_table[key] ~= nil
end

function Language:get_or_default(key, default_language)
    return self.lang_table[key] or default_language:get(key)
end

return Language
