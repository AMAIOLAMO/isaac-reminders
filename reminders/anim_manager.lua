-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

local AnimHandler = {}
AnimHandler.__index = AnimHandler

function AnimHandler.new()
    local obj = setmetatable({
        animations = {}
    }, AnimHandler)
    return obj
end

function AnimHandler:update(dt)
    local rm_anims = {}

    -- for i, anim in ipairs(animations) do
    -- end

end

return AnimHandler
