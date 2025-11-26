local enums = {
    NotifyInfoType = {
        NOTIFY_BEGIN = 1,
        NOTIFY_ICON = 1,
        NOTIFY_TEXT = 2,
        NOTIFY_ICON_TEXT = 3,
        NOTIFY_END = 3
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

return enums
