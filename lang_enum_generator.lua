local lang = {
    -- META
    "LLANG_NATIVE_NAME",

    -- NOTIFY TEXT
    "LNOTIFY_TEXT_HEADER",
    "LNOTIFY_TEXT_HEADER_OK",
    "LNOTIFY_TEXT_HEADER_LOST",
    "LNOTIFY_TEXT_HEADER_FAILED",
    "LNOTIFY_TEXT_ROOM_NIL",

    -- ROOMS
    "LROOM_NULL",
    "LROOM_DEFAULT",
    "LROOM_ERROR",
    "LROOM_SECRET",
    "LROOM_SUPERSECRET",
    "LROOM_ULTRASECRET",
    "LROOM_SHOP",
    "LROOM_TREASURE",
    "LROOM_SACRIFICE",
    "LROOM_LIBRARY",
    "LROOM_ARCADE",
    "LROOM_CHALLENGE",
    "LROOM_PLANETARIUM",
    "LROOM_ISAACS",
    "LROOM_BARREN",
    "LROOM_CHEST",
    "LROOM_DICE",
    "LROOM_CURSE",
    "LROOM_DEVIL",
    "LROOM_ANGEL",
    "LROOM_DUNGEON",
    "LROOM_MINIBOSS",
    "LROOM_BOSS",
    "LROOM_SECRET_EXIT",
    "LROOM_BLUE",
    "LROOM_BOSS_CHALLENGE",

    -- Configs
    "LLANG_CONFIG_GENERAL_NAME",
}


print("local lang_enum = {")
for idx, name in ipairs(lang) do
    print("    " .. name .. " = " .. idx .. ",")
end

print("}")

