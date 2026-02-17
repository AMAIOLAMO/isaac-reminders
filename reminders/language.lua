-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

local Language = {}
Language.__index = Language

function Language.new(lang_table, font, fallback_lang)
    return setmetatable(
        { lang_table = lang_table, font = font, fallback_lang = fallback_lang }, Language
    )
end
function Language:get(key)
    local value = self.lang_table[key]

    if value == nil and self.fallback_lang ~= nil then
        assert(self.fallback_lang ~= nil, tostring(key) .. " does not exist as a key in the translation table, and the fallback language is nil")
        value = self.fallback_lang:get(key)
    end

    assert(value ~= nil, tostring(key) .. " does not exist as a key in the translation table")
    
    return value
end

function Language:has(key)
    return self.lang_table[key] ~= nil
end

function Language:get_or_default(key, default_language)
    return self.lang_table[key] or default_language:get(key)
end

return Language
