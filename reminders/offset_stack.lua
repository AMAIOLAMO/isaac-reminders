-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

-- represents a simple offset stack useful for UI

local OffsetStack = {}
OffsetStack.__index = OffsetStack
OffsetStack.__len = function(obj)
    return #obj.offsets
end

function OffsetStack.new()
    return setmetatable(
        {offsets = {}}, OffsetStack
    )
end

function OffsetStack:clear()
    local n = #self.offsets
    for i=1, n do
        table.remove(self.offsets, i)
    end
end

function OffsetStack:push_static(value)
    self:push_dynamic(function() return value end)
end

function OffsetStack:push_dynamic(offset_calc)
    table.insert(self.offsets, #self.offsets + 1, {
        get_offset = offset_calc
    })
end

function OffsetStack:current()
    local offset = 0
    for _, v in ipairs(self.offsets) do
        offset = offset + v.get_offset()
    end

    return offset
end

function OffsetStack:pop()
    assert(#self.offsets ~= 0, "cannot pop an empty stacked offset")

    return table.remove(self.offsets, #self.offsets)
end

return OffsetStack
