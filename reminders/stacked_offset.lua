-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

-- represents a simple offset stack useful for UI

local StackedOffset = {}
StackedOffset.__index = StackedOffset
StackedOffset.__len = function(obj)
    return #obj.offsets
end

function StackedOffset.new()
    return setmetatable(
        {offsets = {}}, StackedOffset
    )
end

function StackedOffset:clear()
    local n = #self.offsets
    for i=1, n do
        table.remove(self.offsets, i)
    end
end

function StackedOffset:push_static(value)
    self:push_dynamic(function() return value end)
end

function StackedOffset:push_dynamic(offset_calc)
    table.insert(self.offsets, #self.offsets + 1, {
        get_offset = offset_calc
    })
end

function StackedOffset:current()
    local offset = 0
    for _, v in ipairs(self.offsets) do
        offset = offset + v.get_offset()
    end

    return offset
end

function StackedOffset:pop()
    assert(#self.offsets ~= 0, "cannot pop an empty stacked offset")

    return table.remove(self.offsets, #self.offsets)
end


return StackedOffset
