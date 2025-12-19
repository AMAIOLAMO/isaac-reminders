-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

local Timerf = {}
Timerf.__index = Timerf

function Timerf.new(max_span, span)
    local obj = setmetatable({
        span = span,
        max_span = max_span,
    }, Timerf)


    return obj
end

function Timerf:tick_max(dt)
    if not self:max() then
        self:tick(dt)
        return false
    end
    -- else

    return true
end

function Timerf:max()
    return self.span >= self.max_span
end

function Timerf:tick(dt)
    self.span = self.span + dt
end

-- returns the current progress of the timer until max (0 ~ 1)
function Timerf:progress(clamped)
    clamped = true

    if clamped then
        return math.max(math.min(self.span / self.max_span, 1), 0)
    end

    return self.span / self.max_span
end


function Timerf:reset()
    self.span = 0
end

return Timerf
