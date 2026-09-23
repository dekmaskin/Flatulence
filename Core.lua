--[[
    Flatulence
    Plays a random fart sound whenever you use the /fart emote.

    Design goals:
      * One shared Core.lua for every game version (retail, MoP, Cata, Wrath,
        Classic Era). Version differences are isolated to the .toc Interface
        number and the small compatibility shims at the top of this file.
      * Only uses APIs that exist across all supported flavors.
      * Adding new sounds = drop a file in Sounds\ and list it in SOUND_FILES.
--]]

local ADDON_NAME, ns = ...

-- ---------------------------------------------------------------------------
-- Configuration
-- ---------------------------------------------------------------------------

-- List every sound file bundled with the addon here. Paths are relative to
-- the addon folder. Add or remove entries freely; the code picks one at random.
-- Supported formats: .ogg and .mp3 (both are safe across all game versions).
local SOUND_FILES = {
    [[Interface\AddOns\Flatulence\Sounds\fart1.mp3]],
    [[Interface\AddOns\Flatulence\Sounds\fart2.mp3]],
    [[Interface\AddOns\Flatulence\Sounds\fart3.mp3]],
    [[Interface\AddOns\Flatulence\Sounds\fart4.mp3]],
    [[Interface\AddOns\Flatulence\Sounds\fart5.mp3]],
    [[Interface\AddOns\Flatulence\Sounds\fart6.mp3]],
    [[Interface\AddOns\Flatulence\Sounds\fart7.mp3]],
    [[Interface\AddOns\Flatulence\Sounds\fart8.mp3]],
    [[Interface\AddOns\Flatulence\Sounds\fart9.mp3]],
}

-- Relative selection weight for each sound, index-aligned with SOUND_FILES.
-- Higher = more common. A sound with no entry defaults to weight 1. These are
-- relative, not percentages: a weight of 10 is picked 10x as often as a weight
-- of 1. fart8 is the rare "catastrophic shart", so it gets a low weight.
local SOUND_WEIGHTS = {
    [8] = 1,   -- fart8: really long wet shart -- rare (see below for the odds)
}
-- Default weight given to any sound not listed in SOUND_WEIGHTS above. With 8
-- sounds at weight 10 and fart8 at weight 1, fart8 lands ~1 in 81 farts (~1.2%).
local DEFAULT_SOUND_WEIGHT = 10

-- The emote token WoW uses internally for /fart. This is stable across versions.
local FART_EMOTE_TOKEN = "FART"

-- Addon comm prefix. Other players running Flatulence listen for this so they
-- can react. Max 16 characters. Keep this identical across all your installs.
local COMM_PREFIX = "Flatulence"

-- When someone nearby farts, a receiving client reacts with ONE of these
-- reaction, chosen at random and sent as a CUSTOM text emote (the "PlayerName
-- <your text>" format you get from /emote or /e). These read as full sentences
-- in the emote channel and are visible to everyone in range.
--
-- The list is intentionally ordered from EXTREME DISGUST at the top to UTTER
-- DELIGHT at the bottom -- but selection is random, so ordering is only for
-- your reading convenience. Add, remove, or rewrite any line. Each string is
-- appended after your character's name by the game, so write them to continue
-- the sentence "<YourName> ...".
local RESPONSE_EMOTES = {
    -- ---- Extreme disgust ----
    "gags violently and looks for the nearest exit.",
    "recoils in horror, eyes watering from the stench.",
    "clutches their throat and makes a strangled noise.",
    "turns green and staggers backward, gasping for clean air.",
    "vomits a little in their mouth and swallows hard.",
    "pulls their tabard over their nose in sheer desperation.",
    "drops to the floor, overcome by the toxic cloud.",
    "frantically fans the air, coughing and wheezing.",
    "glares with the fury of a thousand suns.",
    "questions every decision that led them to this moment.",
    -- ---- Mild disgust / annoyance ----
    "wrinkles their nose and takes a careful step away.",
    "raises an eyebrow and slowly backs out of the room.",
    "sighs and mutters something about needing new friends.",
    "waves a hand in front of their face, unimpressed.",
    "shoots an accusing glance around the group.",
    "pinches their nose and refuses to breathe.",
    "shakes their head in profound disappointment.",
    "wonders aloud what on Azeroth you ate.",
    "coughs pointedly and edges toward the door.",
    "gives a slow, judgmental clap.",
    -- ---- Neutral / amused ----
    "blinks, unsure whether to laugh or flee.",
    "pretends not to notice but definitely noticed.",
    "raises a single suspicious eyebrow.",
    "stifles a snort and looks away.",
    "quietly awards that one a 7 out of 10.",
    "nods slowly, acknowledging a job well done.",
    -- ---- Delight ----
    "bursts into uncontrollable laughter.",
    "cackles with unhinged glee.",
    "applauds enthusiastically at the masterpiece.",
    "wipes away a tear of pure joy.",
    "cheers and demands an encore.",
    "salutes you with genuine respect.",
    "declares that a bard should write a song about it.",
    "inhales deeply and sighs with inexplicable contentment.",
    "beams with pride as if you were their own child.",
    "throws confetti in celebration of the glorious release.",
    -- ---- Suspiciously into it ----
    "bites their lip and pretends they didn't enjoy that.",
    "blushes furiously and loosens their collar.",
    "fans themselves and whispers, 'do that again.'",
    "shivers and mutters that it's suddenly warm in here.",
    "winks and says they like a partner with... confidence.",
    "raises an intrigued eyebrow and steps a little closer.",
    "swoons dramatically into the nearest chair.",
    "gazes at you with newfound and deeply concerning admiration.",
}

-- Optional: set to true to react with the game's BUILT-IN stock emotes
-- (/cough, /laugh, etc.) instead of the custom text sentences above. The
-- fallback tokens are listed in STOCK_EMOTE_TOKENS below.
local USE_STOCK_EMOTES = false

local STOCK_EMOTE_TOKENS = {
    "COUGH", "CRINGE", "LAUGH", "GIGGLE", "GASP", "SNIFF",
    "PUKE", "DISAPPOINTED", "GLARE", "SHOO", "CONFUSED", "CHUCKLE",
}

-- Custom emote text used by the addon's OWN /prrt command (see below). Unlike
-- /fart, /prrt does not use Blizzard's built-in emote at all -- it posts one of
-- these lines as a custom text emote.
--
-- IMPORTANT: this table is INDEX-ALIGNED with SOUND_FILES. The line at index N
-- is the dedicated "signature" for sound N. When you /prrt, the addon plays a
-- random sound and posts THAT sound's line. Other Flatulence users nearby read
-- the emote off the CHAT_MSG_TEXT_EMOTE event, match the text back to its
-- index, and play the SAME sound -- so everyone in emote range hears the same
-- fart, no group required.
--
-- Because the emote text IS the signal, each line must be UNIQUE and there must
-- be exactly one line per sound file (same count and order as SOUND_FILES).
-- If you add a sound, add a matching line here at the same position. Each
-- string continues the sentence "<YourName> ...".
-- Each line is written to match the SOUND it maps to (see the descriptions in
-- the comments). Keep this in sync if you swap the audio.
local FART_ACTION_EMOTES = {
    [1] = "lets one rip with easy, unhurried confidence.",          -- fart1: standard, medium-long
    [2] = "squeaks out a high, pinched little toot.",               -- fart2: squeaky short
    [3] = "pops off a quick, matter-of-fact fart.",                 -- fart3: standard short
    [4] = "produces a short, distinctly moist splat.",              -- fart4: wet short
    [5] = "unfurls a long, steady, workmanlike rumble.",            -- fart5: standard medium-long
    [6] = "sounds a long, brassy trumpet note from below.",         -- fart6: longer, trumpet-sounding
    [7] = "looses a deep, drawn-out bassy groan.",                  -- fart7: deeper, medium-long
    [8] = "unleashes a catastrophic, wet, seemingly endless shart.",-- fart8: really long wet shart (rare)
    [9] = "fires off one tiny, cheeky blip.",                       -- fart9: very short
}

-- Reverse lookup: normalized emote line -> sound index. Built once at load.
-- Receivers use this to decode which sound to play from an incoming emote.
local FART_ACTION_BY_TEXT = {}

-- Normalize an emote line for robust matching: lowercase and collapse runs of
-- whitespace. This makes the match tolerant of minor formatting differences in
-- how the CHAT_MSG_TEXT_EMOTE string is delivered across game versions.
local function NormalizeEmote(text)
    if type(text) ~= "string" then return nil end
    return text:lower():gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

for index, line in pairs(FART_ACTION_EMOTES) do
    FART_ACTION_BY_TEXT[NormalizeEmote(line)] = index
end

-- Default saved settings.
local DEFAULTS = {
    enabled = true,
    channel = "Master", -- Master plays even if game SFX volume is low.
    lastIndex = 0,      -- used to avoid repeating the same sound twice in a row
    react = true,       -- react to OTHER players' farts with an emote
    reactChance = 100,  -- percent chance to react (0-100), keeps it from being spammy
    lastReactIndex = 0, -- avoid repeating the same reaction emote twice in a row
    hearOthers = true,  -- also play the sound locally when someone nearby farts
}

-- Local runtime state (not saved).
local playerName            -- our own name, used to ignore our own broadcasts
local lastReactAt = 0       -- GetTime() of our last reaction, for cooldown
local REACT_COOLDOWN = 8    -- seconds; prevents emote spam / feedback loops

-- De-duplication: a player who is BOTH grouped with us AND within emote range
-- delivers the same fart twice -- once via the group addon message and once via
-- the CHAT_MSG_TEXT_EMOTE. We remember the last-handled "sender:index" for a
-- short window and drop the duplicate so the sound doesn't play twice.
local lastHandled = {}         -- shortSenderName -> { index = n, at = GetTime() }
local DEDUP_WINDOW = 3         -- seconds

-- ---------------------------------------------------------------------------
-- Compatibility shims (the only place that needs version-specific attention)
-- ---------------------------------------------------------------------------

-- PlaySoundFile signature is the same across versions, but wrap it so we can
-- swap implementations in one spot if a future flavor changes it.
local function PlayFile(path, channel)
    -- Returns willPlay, soundHandle
    return PlaySoundFile(path, channel)
end

-- C_Timer.After exists on all modern clients including Classic, but guard it
-- so the addon degrades gracefully rather than erroring on anything unusual.
local function After(seconds, fn)
    if C_Timer and C_Timer.After then
        C_Timer.After(seconds, fn)
    else
        fn()
    end
end

-- Register our addon message prefix. Modern clients require this before
-- CHAT_MSG_ADDON events for the prefix are delivered.
local function RegisterCommPrefix(prefix)
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    elseif RegisterAddonMessagePrefix then -- very old fallback
        RegisterAddonMessagePrefix(prefix)
    end
end

-- Send an addon message. Prefer the modern C_ChatInfo namespace, fall back to
-- the legacy global for any client that predates it.
local function SendComm(prefix, text, chatType, target)
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        return C_ChatInfo.SendAddonMessage(prefix, text, chatType, target)
    elseif SendAddonMessage then
        return SendAddonMessage(prefix, text, chatType, target)
    end
end

-- Post a custom text emote (the "PlayerName <text>" format). SendChatMessage
-- with the "EMOTE" type is available on every game version.
local function SendTextEmote(text)
    if SendChatMessage then
        SendChatMessage(text, "EMOTE")
    end
end

-- ---------------------------------------------------------------------------
-- Core behaviour
-- ---------------------------------------------------------------------------

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff88ff88Flatulence|r: " .. tostring(msg))
end

-- True while the player is in combat. The addon must stay silent in combat:
-- SendChatMessage/DoEmote are throttled or blocked by Blizzard during combat,
-- and firing sounds/emotes then is both noisy and error-prone. InCombatLockdown
-- exists on every supported flavor; guard it just in case.
local function InCombat()
    return InCombatLockdown and InCombatLockdown() or false
end

-- Weight for a given sound index (falls back to the default weight). Clamped to
-- a minimum of 0; a 0-weight sound is never chosen at random.
local function WeightFor(index)
    local w = SOUND_WEIGHTS[index]
    if w == nil then w = DEFAULT_SOUND_WEIGHT end
    if type(w) ~= "number" or w < 0 then w = 0 end
    return w
end

-- Pick a sound using SOUND_WEIGHTS, avoiding an immediate repeat when we have
-- more than one eligible sound. Weighted roulette: sum the weights, roll a
-- point in that range, and walk until we pass it. The no-repeat pass simply
-- excludes the last-played index from the pool (unless it's the only option).
local function PickSound()
    local count = #SOUND_FILES
    if count == 0 then
        return nil
    elseif count == 1 then
        FlatulenceDB.lastIndex = 1
        return SOUND_FILES[1], 1
    end

    local last = FlatulenceDB.lastIndex

    -- Total weight of all candidates except the last-played one.
    local total = 0
    for i = 1, count do
        if i ~= last then
            total = total + WeightFor(i)
        end
    end

    -- If excluding the last sound leaves nothing pickable (e.g. every other
    -- sound is weight 0), fall back to allowing any positive-weight sound.
    if total <= 0 then
        for i = 1, count do
            total = total + WeightFor(i)
        end
        if total <= 0 then
            -- All weights are zero: degrade to uniform choice so we still play.
            local index = math.random(count)
            FlatulenceDB.lastIndex = index
            return SOUND_FILES[index], index
        end
        last = nil -- last is now allowed, since it's the only weighted option
    end

    -- math.random() returns [0,1); scale into (0, total].
    local roll = math.random() * total
    local index
    for i = 1, count do
        if i ~= last then
            roll = roll - WeightFor(i)
            if roll <= 0 then
                index = i
                break
            end
        end
    end
    -- Floating-point guard: if rounding left us short, take the last candidate.
    if not index then
        for i = count, 1, -1 do
            if i ~= last and WeightFor(i) > 0 then index = i break end
        end
    end

    FlatulenceDB.lastIndex = index
    return SOUND_FILES[index], index
end

-- Play a fart sound. If forcedIndex is given (and valid) that exact sound is
-- played; otherwise a random one is chosen. Returns the index that played, so
-- the caller can broadcast it and have listeners play the same sound.
local function PlayFart(forcedIndex)
    local path, index
    if forcedIndex and SOUND_FILES[forcedIndex] then
        path, index = SOUND_FILES[forcedIndex], forcedIndex
    else
        path, index = PickSound()
    end

    if not path then
        Print("no sound files configured.")
        return nil
    end

    local willPlay = PlayFile(path, FlatulenceDB.channel)
    if not willPlay then
        -- Fall back to the SFX channel if Master was blocked for some reason.
        PlayFile(path, "SFX")
    end

    return index
end

-- ---------------------------------------------------------------------------
-- Reactions: tell nearby Flatulence users, and react to theirs
-- ---------------------------------------------------------------------------

-- Broadcast that we just farted so other Flatulence users can react and play
-- the same sound. The payload is "FART:<index>" where <index> is the sound we
-- played, so listeners can match it (assuming a shared SOUND_FILES list).
-- We send to the group channels the game allows for addon comms. RAID falls
-- back to PARTY automatically when not in a raid; INSTANCE_CHAT covers
-- dungeons/BGs. (There is no "everyone in shouting range" addon channel, so
-- this is limited to players grouped with you -- see README.)
local function BroadcastFart(soundIndex)
    local payload = "FART:" .. tostring(soundIndex or 0)
    if IsInGroup and IsInGroup(2) then          -- 2 == LE_PARTY_CATEGORY_INSTANCE
        SendComm(COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid and IsInRaid() then
        SendComm(COMM_PREFIX, payload, "RAID")
    elseif IsInGroup and IsInGroup() then
        SendComm(COMM_PREFIX, payload, "PARTY")
    end
end

-- Pick a random reaction from the active list, avoiding an immediate repeat.
-- Returns the chosen entry (a custom sentence, or a stock token in stock mode).
local function PickReaction()
    local list = USE_STOCK_EMOTES and STOCK_EMOTE_TOKENS or RESPONSE_EMOTES
    local count = #list
    if count == 0 then return nil end
    if count == 1 then return list[1] end

    local index
    repeat
        index = math.random(count)
    until index ~= FlatulenceDB.lastReactIndex
    FlatulenceDB.lastReactIndex = index
    return list[index]
end

-- Handle someone else's fart: play the same sound locally (if enabled) and
-- react with an emote, respecting settings, a chance roll, and a cooldown that
-- prevents spam/feedback loops.
local function ReactToFart(sourceName, soundIndex)
    -- Never react in combat: reactions post text emotes / stock emotes, which
    -- Blizzard restricts during combat, and combat is no time for farting.
    if InCombat() then return end

    -- Play the sound we "heard". This is independent of your own /fart being
    -- enabled -- it's governed by hearOthers so you can hear farts even if you
    -- keep your own silenced. A forced index that doesn't exist in our list
    -- (mismatched SOUND_FILES) simply falls back to a random sound.
    if FlatulenceDB.hearOthers then
        PlayFart(soundIndex)
    end

    if not FlatulenceDB.react then return end

    local now = GetTime and GetTime() or 0
    if now - lastReactAt < REACT_COOLDOWN then return end

    local chance = tonumber(FlatulenceDB.reactChance) or 100
    if chance < 100 and math.random(100) > chance then return end

    local reaction = PickReaction()
    if not reaction then return end

    lastReactAt = now
    -- Small random delay so a room full of people doesn't react in unison.
    After(0.3 + math.random() * 1.7, function()
        -- Re-check: combat may have started during the delay.
        if InCombat() then return end
        if USE_STOCK_EMOTES then
            DoEmote(reaction)          -- built-in emote token, e.g. "COUGH"
        else
            SendTextEmote(reaction)    -- custom sentence text emote
        end
    end)
end

-- The addon's OWN fart action, triggered by /prrt. Fully independent of
-- Blizzard's /fart emote: plays a random sound and posts THAT sound's dedicated
-- emote line (see FART_ACTION_EMOTES). The emote line doubles as a proximity
-- signal -- any Flatulence user in emote range decodes it via
-- OnTextEmote/CHAT_MSG_TEXT_EMOTE and plays the same sound, no group required.
--
-- We still broadcast on the group addon channel too: groupmates who may be out
-- of emote range (e.g. across a raid instance) still hear it that way. Nearby
-- listeners are de-duplicated in OnTextEmote so they don't play twice.
local function DoFart()
    if not FlatulenceDB.enabled then return end
    if InCombat() then return end

    local index = PlayFart()
    if not index then return end

    BroadcastFart(index)

    local action = FART_ACTION_EMOTES[index]
    if action then
        SendTextEmote(action)
    end
end

-- ---------------------------------------------------------------------------
-- Emote detection
-- ---------------------------------------------------------------------------

-- DoEmote(token) is the function the client calls for every emote, including
-- when the player types /fart. hooksecurefunc lets us react without tainting
-- or overriding Blizzard code, and it works identically on all versions.
-- (This handles the built-in /fart; the addon's own /prrt is handled by
--  DoFart above and does NOT go through here.)
local function OnDoEmote(token)
    if type(token) == "string" and token:upper() == FART_EMOTE_TOKEN then
        if not FlatulenceDB.enabled then return end
        if InCombat() then return end
        local index = PlayFart()
        BroadcastFart(index)
    end
end

-- Return true if we've already handled this exact fart (same sender + sound)
-- within DEDUP_WINDOW seconds, and record it otherwise. Used to collapse the
-- group-message + text-emote double delivery for grouped, in-range players.
local function AlreadyHandled(shortSender, soundIndex)
    if not shortSender then return false end
    local now = GetTime and GetTime() or 0
    local prev = lastHandled[shortSender]
    if prev and prev.index == soundIndex and (now - prev.at) < DEDUP_WINDOW then
        return true
    end
    lastHandled[shortSender] = { index = soundIndex, at = now }
    return false
end

-- Reduce a possibly "Name-Realm" sender to just the character name.
local function ShortName(sender)
    if type(sender) ~= "string" then return sender end
    return sender:match("^[^-]+") or sender
end

-- Handle an incoming addon message from another Flatulence user.
-- Payload is "FART" (legacy) or "FART:<index>".
local function OnAddonMessage(prefix, text, channel, sender)
    if prefix ~= COMM_PREFIX then return end
    if type(text) ~= "string" then return end

    local command, indexStr = text:match("^(%u+):?(%d*)$")
    if command ~= "FART" then return end
    local soundIndex = tonumber(indexStr) -- nil if not provided -> random

    -- Ignore our own broadcast. sender may be "Name" or "Name-Realm".
    local shortSender = ShortName(sender)
    if sender == playerName or shortSender == playerName then
        return
    end

    -- Drop if we already reacted to this same fart via the text emote.
    if AlreadyHandled(shortSender, soundIndex) then return end

    ReactToFart(sender, soundIndex)
end

-- Handle a text emote we can SEE (CHAT_MSG_TEXT_EMOTE). This is the proximity
-- path: the game delivers this event for any /prrt emote posted by a player in
-- emote range, whether or not they are grouped with us. We match the emote text
-- against our known per-sound lines; a hit means a Flatulence user nearby just
-- farted, and the matched index tells us exactly which sound to play.
--
-- Args: (message, playerName, ...) -- message is the raw emote line, e.g.
-- "Bob unleashes a thunderous rip that echoes off the walls." The formatting
-- varies, so we test whether the normalized message CONTAINS one of our lines.
local function OnTextEmote(message, sender)
    if type(message) ~= "string" then return end

    local normalized = NormalizeEmote(message)
    if not normalized then return end

    -- Find which (if any) of our signature lines this emote contains.
    local soundIndex
    for line, index in pairs(FART_ACTION_BY_TEXT) do
        if normalized:find(line, 1, true) then
            soundIndex = index
            break
        end
    end
    if not soundIndex then return end

    -- Ignore our own emote. CHAT_MSG_TEXT_EMOTE's sender arg is the player name.
    local shortSender = ShortName(sender)
    if not sender or sender == playerName or shortSender == playerName then
        return
    end

    -- Drop if we already reacted to this same fart via the group addon message.
    if AlreadyHandled(shortSender, soundIndex) then return end

    ReactToFart(sender, soundIndex)
end

-- ---------------------------------------------------------------------------
-- Slash commands: /fart plays on demand, /flatulence toggles settings
-- ---------------------------------------------------------------------------

local function HandleSlash(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")

    local cmd, rest = msg:match("^(%S*)%s*(.-)$")

    if cmd == "off" then
        FlatulenceDB.enabled = false
        Print("sounds disabled.")
    elseif cmd == "on" then
        FlatulenceDB.enabled = true
        Print("sounds enabled.")
    elseif cmd == "test" then
        if InCombat() then
            Print("not in combat, please.")
        else
            PlayFart()
        end
    elseif cmd == "toggle" then
        FlatulenceDB.enabled = not FlatulenceDB.enabled
        Print(FlatulenceDB.enabled and "sounds enabled." or "sounds disabled.")
    elseif cmd == "react" then
        if rest == "on" then
            FlatulenceDB.react = true
            Print("reactions enabled.")
        elseif rest == "off" then
            FlatulenceDB.react = false
            Print("reactions disabled.")
        elseif tonumber(rest) then
            local chance = math.max(0, math.min(100, math.floor(tonumber(rest))))
            FlatulenceDB.reactChance = chance
            Print("reaction chance set to " .. chance .. "%.")
        else
            FlatulenceDB.react = not FlatulenceDB.react
            Print(FlatulenceDB.react and "reactions enabled." or "reactions disabled.")
        end
    elseif cmd == "hear" then
        if rest == "on" then
            FlatulenceDB.hearOthers = true
            Print("you will now hear others' farts.")
        elseif rest == "off" then
            FlatulenceDB.hearOthers = false
            Print("you will no longer hear others' farts.")
        else
            FlatulenceDB.hearOthers = not FlatulenceDB.hearOthers
            Print(FlatulenceDB.hearOthers and "you will now hear others' farts."
                or "you will no longer hear others' farts.")
        end
    else
        Print("commands:")
        Print("  /flatulence on | off | toggle  -- your fart sound")
        Print("  /flatulence test               -- play a sound now")
        Print("  /flatulence react on | off      -- react to others' farts")
        Print("  /flatulence react <0-100>       -- set reaction chance %")
        Print("  /flatulence hear on | off       -- hear others' farts")
    end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon ~= ADDON_NAME then return end

        -- Initialize / migrate saved variables.
        FlatulenceDB = FlatulenceDB or {}
        for key, value in pairs(DEFAULTS) do
            if FlatulenceDB[key] == nil then
                FlatulenceDB[key] = value
            end
        end

        -- Seed RNG once so the first sound isn't deterministic.
        if math.randomseed then
            math.randomseed(GetTime and math.floor(GetTime() * 1000) or time())
        end

        -- Hook the emote system.
        hooksecurefunc("DoEmote", OnDoEmote)

        -- Register our addon comm prefix so reactions can be received.
        RegisterCommPrefix(COMM_PREFIX)

        -- Register the /flatulence config command. We deliberately do NOT
        -- register /fart ourselves so we never fight Blizzard's real emote.
        SLASH_FLATULENCE1 = "/flatulence"
        SLASH_FLATULENCE2 = "/flat"
        SlashCmdList["FLATULENCE"] = HandleSlash

        -- Register the addon's own independent fart emote: /prrt (and /brap).
        -- This does NOT touch Blizzard's /fart -- it runs DoFart directly.
        SLASH_FLATULENCEPRRT1 = "/prrt"
        SLASH_FLATULENCEPRRT2 = "/brap"
        SlashCmdList["FLATULENCEPRRT"] = DoFart

        self:UnregisterEvent("ADDON_LOADED")
        After(0, function()
            Print("loaded. Use /fart or /prrt and enjoy. Config with /flatulence.")
        end)

    elseif event == "PLAYER_LOGIN" then
        -- Cache our own name so we can ignore our own broadcasts.
        playerName = UnitName("player")

    elseif event == "CHAT_MSG_ADDON" then
        OnAddonMessage(...)

    elseif event == "CHAT_MSG_TEXT_EMOTE" then
        -- Args: text, playerName, languageName, ... -- we need the first two.
        OnTextEmote(...)
    end
end)
