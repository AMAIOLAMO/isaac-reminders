-- AUTHOR: CxRedix
-- Copyright 2025 CxRedix
-- THIS FILE IS LICENSED UNDER GPL-3.0-or-later by CxRedix

local lang = include("reminders.language")
local LE = include("reminders.language_enum")
local Languages = {}

local default_language_font = Font()
default_language_font:Load("font/teammeatex/teammeatex10.fnt")

-- potential bug, if we use the key while the language has no native name(LE.LLANG_NATIVE_NAME), it will fallback to english
-- even if the other values are still in their respective language. Maintain values for now

Languages.English = lang.new({
    [LE.LNOTIFY_TEXT_HEADER       ] = "=== ![Missed Special Rooms]! === ",
    [LE.LNOTIFY_TEXT_HEADER_OK    ] = "No Missed Special Rooms :)",
    [LE.LNOTIFY_TEXT_HEADER_LOST  ] = "Oh no! You have Curse of The Lost :(",
    [LE.LNOTIFY_TEXT_HEADER_FAILED] = "Notify header is somehow broken! Reset Config to fix this.",
    [LE.LNOTIFY_TEXT_ROOM_NIL     ] = "Nil Room of type: %d", -- requires number formatting instead of just %d? :/

    [LE.LROOM_NULL       ] = "NULL Room",
    [LE.LROOM_DEFAULT    ] = "Default Room",
    [LE.LROOM_ERROR      ] = "Error Room",
    [LE.LROOM_SECRET     ] = "Secret Room",
    [LE.LROOM_SUPERSECRET] = "Super Secret Room",
    [LE.LROOM_ULTRASECRET] = "Ultra Secret Room",
    [LE.LROOM_SHOP       ] = "Shop",
    [LE.LROOM_TREASURE   ] = "Treasure Room",
    [LE.LROOM_SACRIFICE  ] = "Sacrifice Room",
    [LE.LROOM_LIBRARY    ] = "Library",
    [LE.LROOM_ARCADE     ] = "Arcade",
    [LE.LROOM_CHALLENGE  ] = "Challenge Room",
    [LE.LROOM_PLANETARIUM] = "Planetarium",
    [LE.LROOM_ISAACS     ] = "Bedroom",
    [LE.LROOM_BARREN     ] = "Barren Bedroom",
    [LE.LROOM_CHEST      ] = "Vault Room",
    [LE.LROOM_DICE       ] = "Dice Room",
    [LE.LROOM_CURSE      ] = "Curse Room",
    [LE.LROOM_DEVIL      ] = "Devil Room",
    [LE.LROOM_ANGEL      ] = "Angel Room",
    [LE.LROOM_DUNGEON    ] = "Dungeon Room(Crawlspace)",
    [LE.LROOM_MINIBOSS   ] = "Miniboss Room",
    [LE.LROOM_BOSS       ] = "Boss Room",
    [LE.LROOM_SECRET_EXIT] = "Alt Path Room",
    [LE.LROOM_BLUE       ] = "Blue Womb Room",

    [LE.LROOM_BOSS_CHALLENGE] = "Boss Challenge Room",

    [LE.LLANG_NATIVE_NAME] = "English",

    [LE.LLANG_CONFIG_GENERAL_NAME] = "General",
}, default_language_font)

Languages.Chinese = lang.new({
    [LE.LNOTIFY_TEXT_HEADER       ] = "=== ![未探索的特殊房间]! === ",
    [LE.LNOTIFY_TEXT_HEADER_OK    ] = "特殊房间全部探索完成 :)",
    [LE.LNOTIFY_TEXT_HEADER_LOST  ] = "完蛋了! 你得了迷宫诅咒! :(",
    [LE.LNOTIFY_TEXT_HEADER_FAILED] = "诶，提示信息好像出错了! 你可以尝试通过重置设置去修复。",
    [LE.LNOTIFY_TEXT_ROOM_NIL     ] = "未知房间类型: %d",

    [LE.LROOM_NULL       ] = "未知房",
    [LE.LROOM_DEFAULT    ] = "默认房",
    [LE.LROOM_ERROR      ] = "错误房",
    [LE.LROOM_SECRET     ] = "隐藏房",
    [LE.LROOM_SUPERSECRET] = "超级隐藏房",
    [LE.LROOM_ULTRASECRET] = "究极隐藏房",
    [LE.LROOM_SHOP       ] = "商店",
    [LE.LROOM_TREASURE   ] = "宝箱房",
    [LE.LROOM_SACRIFICE  ] = "献祭房",
    [LE.LROOM_LIBRARY    ] = "图书馆",
    [LE.LROOM_ARCADE     ] = "游戏厅",
    [LE.LROOM_CHALLENGE  ] = "挑战房",
    [LE.LROOM_PLANETARIUM] = "星象房",
    [LE.LROOM_ISAACS     ] = "卧室",
    [LE.LROOM_BARREN     ] = "肮脏的卧室",
    [LE.LROOM_CHEST      ] = "宝库",
    [LE.LROOM_DICE       ] = "骰子房",
    [LE.LROOM_CURSE      ] = "诅咒房",
    [LE.LROOM_DEVIL      ] = "恶魔房",
    [LE.LROOM_ANGEL      ] = "天使房",
    [LE.LROOM_DUNGEON    ] = "地牢(夹层)",
    [LE.LROOM_MINIBOSS   ] = "小头目房",
    [LE.LROOM_BOSS       ] = "头目房",
    [LE.LROOM_SECRET_EXIT] = "隐秘出口",
    [LE.LROOM_BLUE       ] = "蓝子宫房",

    [LE.LROOM_BOSS_CHALLENGE] = "头目挑战房",

    [LE.LLANG_NATIVE_NAME] = "中文",


    [LE.LLANG_CONFIG_GENERAL_NAME] = "通用",
}, default_language_font, Languages.English)

Languages.Russian = lang.new({
    [LE.LNOTIFY_TEXT_HEADER       ] = "=== ![Пропущенные особенные комнаты]! === ",
    [LE.LNOTIFY_TEXT_HEADER_OK    ] = "Нет пропущенных особенных комнат :)",
    [LE.LNOTIFY_TEXT_HEADER_LOST  ] = "О нет! У вас Проклятие Потерянного! :(",
    [LE.LNOTIFY_TEXT_HEADER_FAILED] = "Заголовок уведомлений почему-то сломан! Сбросьте конфигурацию, чтобы это починить.",

    [LE.LNOTIFY_TEXT_ROOM_NIL     ] = "Неизвестная комната типа: %d",

    [LE.LROOM_NULL       ] = "Нулевая комната",
    [LE.LROOM_DEFAULT    ] = "Обычная комната",
    [LE.LROOM_ERROR      ] = "Комната ошибки",
    [LE.LROOM_SECRET     ] = "Секретная комната",
    [LE.LROOM_SUPERSECRET] = "Суперсекретная комната",
    [LE.LROOM_ULTRASECRET] = "Ультра секретная комната",
    [LE.LROOM_SHOP       ] = "Магазин",
    [LE.LROOM_TREASURE   ] = "Комната сокровищ",
    [LE.LROOM_SACRIFICE  ] = "Комната жертвоприношения",
    [LE.LROOM_LIBRARY    ] = "Библиотека",
    [LE.LROOM_ARCADE     ] = "Аркада",
    [LE.LROOM_CHALLENGE  ] = "Комната испытания",
    [LE.LROOM_PLANETARIUM] = "Планетарий",
    [LE.LROOM_ISAACS     ] = "Спальня",
    [LE.LROOM_BARREN     ] = "Пустая спальня",
    [LE.LROOM_CHEST      ] = "Хранилище",
    [LE.LROOM_DICE       ] = "Комната кости",
    [LE.LROOM_CURSE      ] = "Проклятая комната",
    [LE.LROOM_DEVIL      ] = "Комната дьявола",
    [LE.LROOM_ANGEL      ] = "Комната ангела",
    [LE.LROOM_DUNGEON    ] = "Подземная комната",
    [LE.LROOM_MINIBOSS   ] = "Комната мини-босса",
    [LE.LROOM_BOSS       ] = "Комната босса",
    [LE.LROOM_SECRET_EXIT] = "Комната альт-пути",
    [LE.LROOM_BLUE       ] = "Комната к ???",

    [LE.LROOM_BOSS_CHALLENGE] = "Комната испытания с боссом",

    [LE.LLANG_NATIVE_NAME] = "Русский",
}, default_language_font, Languages.English)

-- Maintain the associations of language and their respective id, this allows certain languages
-- to now show up yet in the game if not associated to do so

Languages.lang_ids = {
    BEGIN = 1,

    English = 1,
    Chinese = 2,
    Russian = 3,

    END = 3,
}


Languages.lang_id_to_language = {
    [Languages.lang_ids.English] = Languages.English,
    [Languages.lang_ids.Chinese] = Languages.Chinese,
    [Languages.lang_ids.Russian] = Languages.Russian
}

return Languages
