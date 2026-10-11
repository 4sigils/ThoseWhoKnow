-- Constants and URLs. Edit here to retarget the script.
local C = ...

C.cfg = {
    -- data files live at the repo root (Animations.lua / IgnoredAnimations.lua)
    DATA_URL    = C.BASE .. "Animations.lua",
    IGNORE_URL  = C.BASE .. "IgnoredAnimations.lua",
    NEXA_SOURCE = "https://raw.githubusercontent.com/OgTen/Nexa-UI/refs/heads/main/nexa-ui.lua",
    OFFSETS_URL = "https://offsets.imtheo.lol/Offsets.json",

    LOGO_URL = "https://cdn.discordapp.com/attachments/1402876855840804895/1558405775167201400/noFilter_1.png?ex=6acb51fa&is=6aca007a&hm=8ff9153ff0a850fa34512fbe989660978c0583fa43b6a417caac6a61de7189fd&",
    -- Embedded 4x4 black PNG (no download, no 1920x1080 texture to decode and draw every frame)
    BG_IMG   = "\137\080\078\071\013\010\026\010\000\000\000\013\073\072\068\082\000\000\000\004\000\000\000\004\008\006\000\000\000\169\241\158\126\000\000\000\079\073\068\065\084\120\001\001\068\000\187\255\000\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\000\255\000\000\000\255\000\000\000\255\000\000\000\255\006\090\015\241\170\028\251\110\000\000\000\000\073\069\078\068\174\066\096\130",

    KEY_PARRY  = 0x46, -- F
    KEY_DODGE  = 0x51, -- Q
    KEY_JUMP   = 0x20, -- Space
    KEY_CROUCH = 0xA2, -- Left Ctrl

    -- All animation timings in the data file are tuned for roughly this ping (ms).
    BASE_PING = 60,

    SCAN_INTERVAL    = 0.018,
    TRACKER_INTERVAL = 0.05,
    HIST_SLOTS = 10,
    HIST_MAX   = 50,

    CONFIG_FILE  = "Deepwoken_Config.json",
    FRIENDS_FILE = "Deepwoken_ExcludedFriends.json",
    GUILDS_FILE  = "Deepwoken_ExcludedGuilds.json",
}
