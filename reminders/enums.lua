local enums = {
    NotifyInfoType = {
        NOTIFY_BEGIN     = 1,
        NOTIFY_ICON      = 1,
        NOTIFY_TEXT      = 2,
        NOTIFY_ICON_TEXT = 3,
        NOTIFY_END       = 3
    },
    Sizes = {
        SIZES_BEGIN  = 1,
        SIZES_SMALL  = 1,
        SIZES_MEDIUM = 2,
        SIZES_LARGE  = 3,
        SIZES_END    = 3,
    }

}

function enums.NotifyInfoType:to_description(type)
    if type == self.NOTIFY_ICON_TEXT then
        return "Notify Icon and Text"

    elseif type == self.NOTIFY_ICON then
        return "Notify Icon Only"

    elseif type == self.NOTIFY_TEXT then
        return "Notify Text Only"
    end
end

function enums.Sizes:to_description(type)
    if type == self.SIZES_SMALL then
        return "Small"

    elseif type == self.SIZES_MEDIUM then
        return "Medium"

    elseif type == self.SIZES_LARGE then
        return "Large"
    end
end

return enums
