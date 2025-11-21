-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

local ILogger = {}
ILogger.__index = ILogger

function ILogger.new(prefix)
    local logger = setmetadata({
        prefix = prefix,
    }, ILogger)

    return logger
end

local function log_base(log_level, prefix, fmt, ...)
    local time_str = tostring(Isaac.GetTime())
    local result_msg = arg and
    string.format(fmt, table.unpack(arg)) or fmt

    print(
        string.format("[%s]%s[%s]: %s", log_level, prefix, time_str, result_msg)
    )
end

function ILogger.info(fmt, ...)
    log_base("[INFO]", self.prefix, fmt, table.unpack(arg or {}))
end

function ILogger.warn(fmt, ...)
    log_base("[WARN]", self.prefix, fmt, table.unpack(arg or {}))
end

function ILogger.err(fmt, ...)
    log_base("[ERR]", self.prefix, fmt, table.unpack(arg or {}))
end

return ILogger
