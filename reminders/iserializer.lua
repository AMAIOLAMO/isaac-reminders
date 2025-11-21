-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix
--
-- encodes common userdata into a simpler table, useful for json serialization
local ISerializer = {}

function ISerializer.encode_color(color)
    return {
        color.R, color.G, color.B, color.A, color.RO, color.GO, color.BO
    }
end

function ISerializer.decode_color(color)
    return Color(color[1], color[2], color[3], color[4], color[5], color[6], color[7])
end

function ISerializer.encode_vector(vec)
    return {
        vec.X, vec.Y
    }
end

function ISerializer.decode_vector(vec)
    return Vector(vec[1], vec[2])
end

function ISerializer.encode_kcolor(kcolor)
    return {
        kcolor.Red, kcolor.Green, kcolor.Blue, kcolor.Alpha
    }
end

function ISerializer.decode_kcolor(kcolor)
    return KColor(kcolor[1], kcolor[2], kcolor[3], kcolor[4])
end

return ISerializer
