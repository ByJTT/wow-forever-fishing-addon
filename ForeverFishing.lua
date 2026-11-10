-- wow-forever-fishing-addon (WoW Forever) — ByJTT
-- Display name: "WoW Forever Fishing Addon ByJTT" (AddonName ByJTT style)
-- One-click fishing, lure & pole helpers, bite alert + catch tracker.
-- https://github.com/ByJTT/wow-forever-fishing-addon

local ADDON_NAME = "ForeverFishing" -- in-game folder/TOC name (must remain stable)
local REPO_NAME  = "wow-forever-fishing-addon"
local DISPLAY_NAME = "WoW Forever Fishing Addon ByJTT"
local ns = {}
local VERSION = "1.0.0"
local SCHEMA = 1
local DB

-- ByJTT foundation namespace (shared pattern with sister addons)
ByJTT = ByJTT or {}
ByJTT.Brand = ByJTT.Brand or {
    name = "ByJTT",
    web = "https://byjtt.com",
    github = "https://github.com/ByJTT",
    -- PLACEHOLDER: replace with your real Buy Me a Coffee URL when ready.
    support = "https://buymeacoffee.com/ByJTT",
    supportLabel = "Buy Me a Coffee",
}
ByJTT.Addons = ByJTT.Addons or {}
ByJTT.Addons[ADDON_NAME] = ns
ns._version = VERSION
ns._schema = SCHEMA
ns._repo = REPO_NAME
ns._displayName = DISPLAY_NAME
ns._brand = ByJTT.Brand

--------------------------------------------------------------------------------
-- Constants: fishing spell + pole + lure data (classic values, name fallbacks)
--------------------------------------------------------------------------------
-- Fishing profession spell (classic ID 7620). Resolved by ID, falls back to name.
local FISHING_SPELL_ID = 7620
local FISHING_SPELL_NAMES = { "Fishing" }

-- Fishing poles (known classic items — ranked for "best pole in bags").
-- id + fallback name so the addon survives missing/incorrect IDs.
local POLES = {
    { id = 19970, name = "Arcanite Fishing Pole" },       -- +40
    { id = 19022, name = "Nat Pagle's Extreme Angler FC-5000" }, -- +20
    { id = 45991, name = "Bone Fishing Pole" },           -- classic-era alternates below
    { id = 45992, name = "Jeweled Fishing Pole" },
    { id = 120363, name = "Dentrium Power Pole" },
    { id = 8464, name = "Blump Family Fishing Pole" },    -- +3
    { id = 8465, name = "Big Iron Fishing Pole" },       -- +20
    { id = 6256, name = "Fishing Pole" },                -- vendor starter
}
ns.POLES = POLES

-- Lures / pole enchants: id + fallback name + bonus. Best-available pick wins.
local LURES = {
    { id = 6532, name = "Bright Baubles",                 bonus = 25  },
    { id = 6533, name = "Aquadynamic Fish Attractor",     bonus = 100 },
    { id = 6529, name = "Shiny Bauble",                   bonus = 25  },
    { id = 68049, name = "Heat-Treated Spinning Lure",    bonus = 15  },
    { id = 34861, name = "Sharpened Fish Hook",           bonus = 100 },
    { id = 7307, name = "Flesh Eating Worm",              bonus = 0   },
    { id = 34832, name = "Nightcrawlers",                 bonus = 50  },
}
ns.LURES = LURES

--------------------------------------------------------------------------------
-- Compat / helpers (WoW Forever: Interface 16001/30300; feature-detect + pcall)
--------------------------------------------------------------------------------
local Compat = {}
ns.Compat = Compat

function Compat.SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if ok then return a, b, c, d, e end
    return nil
end

local function SpellNameByID(id)
    if id and C_Spell and C_Spell.GetSpellInfo then
        local info = Compat.SafeCall(C_Spell.GetSpellInfo, id)
        if type(info) == "table" and info.name and info.name ~= "" then
            return info.name, info.iconID, info.spellID or id
        end
        if type(info) == "string" and info ~= "" then return info, nil, id end
    end
    if id and GetSpellInfo then
        local name, _, icon = GetSpellInfo(id)
        if name and name ~= "" then return name, icon, id end
    end
    return nil, nil, nil
end

local function FishingSpellName()
    local name = SpellNameByID(FISHING_SPELL_ID)
    if name and name ~= "" then return name end
    for _, n in ipairs(FISHING_SPELL_NAMES) do
        if n and n ~= "" and GetSpellInfo then
            local found = Compat.SafeCall(GetSpellInfo, n)
            if found and found ~= "" then return n end
        end
    end
    return "Fishing"
end
ns.FishingSpellName = FishingSpellName

local function IsSpellKnownAny(ids, names)
    for _, id in ipairs(ids or {}) do
        if id and (Compat.SafeCall(IsPlayerSpell, id) or Compat.SafeCall(IsSpellKnown, id)) then return true end
        if id and GetSpellInfo then
            local n = Compat.SafeCall(GetSpellInfo, id)
            if n and n ~= "" then return true end
        end
    end
    for _, n in ipairs(names or {}) do
        if n and n ~= "" and GetSpellInfo then
            local found = Compat.SafeCall(GetSpellInfo, n)
            if found and found ~= "" then return true end
        end
    end
    return false
end

local function ItemCountAny(entries)
    local best, bestEntry = 0, nil
    for _, e in ipairs(entries or {}) do
        local count = 0
        if e.id and GetItemCount then
            count = Compat.SafeCall(GetItemCount, e.id, false, false, false) or 0
        end
        if (not count or count == 0) and e.name and GetItemCount then
            count = Compat.SafeCall(GetItemCount, e.name, false, false, false) or 0
        end
        if count and count > 0 then
            if not bestEntry or (e.bonus or 0) > (bestEntry.bonus or 0) or ((e.bonus or 0) == (bestEntry.bonus or 0) and count > best) then
                best, bestEntry = count, e
            end
        end
    end
    return best, bestEntry
end

local function CurrentZoneName()
    if GetRealZoneText then
        local z = Compat.SafeCall(GetRealZoneText)
        if z and z ~= "" then return z end
    end
    if GetZoneText then
        local z = Compat.SafeCall(GetZoneText)
        if z and z ~= "" then return z end
    end
    return "Unknown"
end
ns.CurrentZoneName = CurrentZoneName

local function PlayerFishingSkill()
    -- Classic: Fishing is a secondary profession; skill rank via GetProfessions/GetProfessionInfo if present.
    if GetProfessions and GetProfessionInfo then
        local profs = { Compat.SafeCall(GetProfessions) }
        for _, pid in ipairs(profs) do
            if pid then
                local name, _, rank = Compat.SafeCall(GetProfessionInfo, pid)
                if name and (name == "Fishing" or name:lower():find("fish")) then
                    return rank or 0
                end
            end
        end
    end
    return nil
end
ns.PlayerFishingSkill = PlayerFishingSkill

local function ProfessionFishingKnown()
    return IsSpellKnownAny({ FISHING_SPELL_ID }, FISHING_SPELL_NAMES)
end

--------------------------------------------------------------------------------
-- SavedVariables: defaults, schema (additive migrations, never drop keys)
--------------------------------------------------------------------------------
local GLOBAL_DEFAULTS = {
    _schema = SCHEMA,
    _version = VERSION,
    locked = true,
    scale = 1.0,
    alpha = 1.0,
    pulse = true,
    sound = true,
    biteAlert = true,      -- sound + flash on bobber bite
    autoLure = false,      -- prompt/one-click re-lure (never fully automatic)
    point = "CENTER", relPoint = "CENTER", x = 0, y = -190,
    debug = false,
    firstRun = true,
    onboardingDone = false,
    onboardingDismissed = false,
    -- tracker
    catches = {},          -- [itemName] = total count
    zones = {},            -- [zone] = { [itemName] = count }
    sessions = {},         -- list of { started, ended, casts, catches }
    session = nil,         -- active session { started, casts, catches }
    lastBiteAt = 0,
}

local function EnsureDB()
    if type(ForeverFishingDB) ~= "table" then ForeverFishingDB = {} end
    DB = ForeverFishingDB
end

local function ApplyDefaults(dst, src)
    for k, v in pairs(src) do
        if dst[k] == nil then
            if type(v) == "table" then
                local t = {}
                ApplyDefaults(t, v)
                dst[k] = t
            else
                dst[k] = v
            end
        end
    end
end

local function MigrateDB()
    if type(DB.catches) ~= "table" then DB.catches = {} end
    if type(DB.zones) ~= "table" then DB.zones = {} end
    if type(DB.sessions) ~= "table" then DB.sessions = {} end
    ApplyDefaults(DB, GLOBAL_DEFAULTS)
    DB._schema = SCHEMA
    DB._version = VERSION
end

--------------------------------------------------------------------------------
-- UI root + helpers
--------------------------------------------------------------------------------
local root = CreateFrame("Frame", ADDON_NAME .. "Frame", UIParent)
root:SetClampedToScreen(true)
root:SetMovable(true)
root:EnableMouse(false)
root:SetFrameStrata("MEDIUM")
root:SetFrameLevel(50)
root:Hide()

local buttons = {}
local pool = {}
local pendingSecure = false
local pulseT = 0
local flashUntil = 0 -- bite flash timer
ns.root = root

local function Print(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff4dd0e6WoW Forever Fishing Addon ByJTT:|r " .. tostring(msg))
    end
end
local function Debug(msg)
    if DB and DB.debug then Print("|cffaaaaaa[debug]|r " .. tostring(msg)) end
end
ns.Print = Print
ns.Debug = Debug

local function SavePosition()
    if not DB then return end
    local point, _, relPoint, x, y = root:GetPoint(1)
    if point then DB.point, DB.relPoint, DB.x, DB.y = point, relPoint, x, y end
end

local function ApplyPosition()
    if not DB then return end
    root:ClearAllPoints()
    root:SetPoint(DB.point or "CENTER", UIParent, DB.relPoint or "CENTER", DB.x or 0, DB.y or -190)
end

local function ApplyVisuals()
    if not DB then return end
    root:SetScale(DB.scale or 1)
    root:SetAlpha(DB.alpha or 1)
end

-- Secure attribute apply — ONLY out of combat.
local function UpdateSecure(btn, action)
    if InCombatLockdown and InCombatLockdown() then pendingSecure = true; return false end
    btn:SetAttribute("type1", nil); btn:SetAttribute("spell1", nil)
    btn:SetAttribute("macrotext1", nil); btn:SetAttribute("item1", nil)
    btn:SetAttribute("*type1", nil); btn:SetAttribute("*spell1", nil)
    btn:SetAttribute("*macrotext1", nil); btn:SetAttribute("*item1", nil)
    btn:SetAttribute("useOnKeyDown", false)
    if action.kind == "spell" then
        btn:SetAttribute("type", "spell")
        btn:SetAttribute("spell", action.spell)
        btn:SetAttribute("macrotext", nil)
        btn:SetAttribute("item", nil)
    elseif action.kind == "item" then
        btn:SetAttribute("type", "item")
        btn:SetAttribute("item", action.item)
        btn:SetAttribute("spell", nil)
        btn:SetAttribute("macrotext", nil)
    elseif action.kind == "macro" then
        btn:SetAttribute("type", "macro")
        btn:SetAttribute("macrotext", action.macro)
        btn:SetAttribute("spell", nil)
        btn:SetAttribute("item", nil)
    end
    btn._mode = action.kind
    return true
end

local function InCombat()
    return (InCombatLockdown and InCombatLockdown()) or false
end

--------------------------------------------------------------------------------
-- Buttons: cast, lure, tracker (skinning, WoW-authentic minimal)
--------------------------------------------------------------------------------
local function SetTooltip(btn)
    GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
    local a = btn._action
    GameTooltip:SetText(btn._title or "Fishing", 1, 1, 1)
    if a and a.hint then GameTooltip:AddLine(a.hint, 0.9, 0.9, 0.9, true) end
    if btn._status then GameTooltip:AddLine(btn._status, 0.8, 0.9, 1, true) end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cff00ff00Click|r " .. (btn._verb or "to use"), 0.9, 0.9, 0.9)
    GameTooltip:AddLine("|cff888888Shift+Drag|r to move  •  |cff888888/ffish config|r settings", 0.55, 0.55, 0.55)
    GameTooltip:AddLine("|cff888888WoW Forever Fishing Addon ByJTT|r", 0.45, 0.45, 0.45)
    GameTooltip:Show()
end

local function SkinIcon(btn, r, g, b)
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 3, -3)
    icon:SetPoint("BOTTOMRIGHT", -3, 3)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetTexture(134400)
    btn.icon = icon
    local function Edge(point, rel, x, y, w, h)
        local e = btn:CreateTexture(nil, "BORDER")
        e:SetColorTexture(0, 0, 0, 0.9)
        e:SetPoint(point, btn, rel, x, y)
        e:SetSize(w, h)
        return e
    end
    Edge("TOPLEFT", "TOPLEFT", 0, 0, 40, 1)
    Edge("BOTTOMLEFT", "BOTTOMLEFT", 0, 0, 40, 1)
    Edge("TOPLEFT", "TOPLEFT", 0, 0, 1, 40)
    Edge("TOPRIGHT", "TOPRIGHT", 0, 0, 1, 40)
    local inner = {}
    local function RingEdge(point, rel, x, y, w, h)
        local e = btn:CreateTexture(nil, "OVERLAY", nil, 1)
        e:SetColorTexture(r, g, b, 0.95)
        e:SetPoint(point, btn, rel, x, y)
        e:SetSize(w, h)
        table.insert(inner, e)
    end
    RingEdge("TOPLEFT", "TOPLEFT", 1, -1, 38, 2)
    RingEdge("BOTTOMLEFT", "BOTTOMLEFT", 1, 1, 38, 2)
    RingEdge("TOPLEFT", "TOPLEFT", 1, -1, 2, 38)
    RingEdge("TOPRIGHT", "TOPRIGHT", -1, -1, 2, 38)
    btn._ringEdges = inner
    btn._ringColor = { r, g, b }
    local hl = btn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetPoint("TOPLEFT", 3, -3)
    hl:SetPoint("BOTTOMRIGHT", -3, 3)
    hl:SetColorTexture(1, 1, 1, 0.18)
    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOP", btn, "BOTTOM", 0, -1)
    label:SetTextColor(r, g, b)
    btn.label = label
end

local function AcquireButton(id, r, g, b, size)
    if buttons[id] then return buttons[id] end
    local btn = table.remove(pool)
    if not btn then
        local name = ADDON_NAME .. "_Btn_" .. tostring(id) .. "_" .. tostring(math.random(1000, 9999))
        btn = CreateFrame("Button", name, root, "SecureActionButtonTemplate")
        btn:SetSize(size or 40, size or 40)
        btn:EnableMouse(true)
        btn:RegisterForClicks("AnyUp", "AnyDown")
        btn:RegisterForDrag("LeftButton")
        SkinIcon(btn, r or 0.3, g or 0.8, b or 0.9)
        btn:SetScript("OnDragStart", function()
            if not InCombat() and DB and (not DB.locked or IsShiftKeyDown()) then root:StartMoving() end
        end)
        btn:SetScript("OnDragStop", function()
            if not InCombat() then root:StopMovingOrSizing(); SavePosition() end
        end)
        btn:SetScript("OnEnter", function(self) SetTooltip(self) end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    buttons[id] = btn
    return btn
end

local function Layout(shown)
    local n = #shown
    if n == 0 then root:Hide(); return end
    local w, h, gap = 40, 40, 8
    root:SetSize(n * w + (n - 1) * gap, h + 14)
    for i, b in ipairs(shown) do
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", root, "TOPLEFT", (i - 1) * (w + gap), 0)
    end
end

root:SetScript("OnUpdate", function(self, elapsed)
    if not DB then return end
    local active = (DB.pulse and self:IsShown())
    local flashing = flashUntil > 0
    if flashing then flashUntil = flashUntil - elapsed end
    if not active and not flashing then return end
    pulseT = pulseT + elapsed
    local a = 0.45 + 0.5 * (0.5 + 0.5 * math.sin(pulseT * 4.0))
    if flashing then a = 1.0 end
    for _, b in pairs(buttons) do
        if b:IsShown() and b._ringEdges then
            local c = b._ringColor or { 0.3, 0.8, 0.9 }
            for _, e in ipairs(b._ringEdges) do e:SetColorTexture(c[1], c[2], c[3], a) end
        end
    end
end)

local function PlayBiteHint()
    if DB and DB.sound and DB.biteAlert and PlaySound then
        pcall(PlaySound, 569593)
    end
end

--------------------------------------------------------------------------------
-- Tracker state
--------------------------------------------------------------------------------
local sessionCasts, sessionCatches = 0, 0
local fishingActive = false -- bobber out

local function EnsureSession()
    if not DB.session then
        DB.session = { started = time(), casts = 0, catches = 0 }
        sessionCasts, sessionCatches = 0, 0
    end
    return DB.session
end

local function EndSession()
    local s = DB.session
    if s then
        s.ended = time()
        s.casts = sessionCasts
        s.catches = sessionCatches
        table.insert(DB.sessions, s)
        -- keep last 50 sessions
        while #DB.sessions > 50 do table.remove(DB.sessions, 1) end
    end
    DB.session = nil
    sessionCasts, sessionCatches = 0, 0
end

local function RecordLoot(itemLink, quantity)
    if not itemLink then return end
    local name = itemLink:match("%[(.-)%]") or itemLink
    quantity = quantity or 1
    DB.catches[name] = (DB.catches[name] or 0) + quantity
    local zone = CurrentZoneName()
    DB.zones[zone] = DB.zones[zone] or {}
    DB.zones[zone][name] = (DB.zones[zone][name] or 0) + quantity
    sessionCatches = sessionCatches + 1
    if DB.session then DB.session.catches = sessionCatches end
    Debug("caught: " .. tostring(name) .. " x" .. tostring(quantity) .. " in " .. tostring(zone))
end

--------------------------------------------------------------------------------
-- Refresh: build button plan (read) then apply (secure)
--------------------------------------------------------------------------------
local function BuildButtonStates()
    local states = {}
    local spellName = FishingSpellName()
    local known = ProfessionFishingKnown()
    local skill = PlayerFishingSkill()

    -- 1. Cast button (always present)
    local status = nil
    if not known then
        status = "Fishing not learned — visit a fishing trainer."
    elseif skill then
        status = "Skill " .. tostring(skill)
    end
    table.insert(states, {
        id = "cast",
        title = "Cast Fishing",
        verb = "to cast",
        icon = "Interface\\Icons\\INV_Fishingpole_01",
        hint = "One-click cast. Double-click also works.",
        status = status,
        color = { 0.30, 0.83, 0.91 },
        enabled = known,
        dimmed = not known,
        action = { kind = "spell", spell = spellName },
    })

    -- 2. Lure button (only when a lure exists in bags)
    local lureCount, bestLure = ItemCountAny(LURES)
    if bestLure then
        table.insert(states, {
            id = "lure",
            title = "Apply " .. (bestLure.name or "Lure"),
            verb = "to apply lure",
            icon = "Interface\\Icons\\INV_Misc_Food_26",
            hint = (bestLure.name or "Lure") .. " (+" .. tostring(bestLure.bonus or 0) .. ") x" .. tostring(lureCount),
            status = "Best lure in bags: " .. (bestLure.name or "?"),
            color = { 0.55, 0.90, 0.45 },
            enabled = true,
            dimmed = false,
            action = { kind = "item", item = bestLure.name or bestLure.id },
            _lureEntry = bestLure,
        })
    end

    -- 3. Pole info is shown in stats/tooltip; no extra button (keeps bar minimal).

    return states
end

local function ApplyStates(states)
    if InCombat() then pendingSecure = true; return end
    pendingSecure = false
    local shown = {}
    local active = {}
    for _, st in ipairs(states) do
        local btn = AcquireButton(st.id, st.color[1], st.color[2], st.color[3])
        btn._action = st.action
        btn._title = st.title
        btn._verb = st.verb
        btn._status = st.status
        if btn.icon then
            btn.icon:SetTexture(st.icon or 134400)
            btn.icon:SetDesaturated(st.dimmed and true or false)
            btn.icon:SetAlpha(st.dimmed and 0.55 or 1)
        end
        if btn.label then btn.label:SetText(st.id == "cast" and "Fish" or (st.id == "lure" and "Lure" or "?")) end
        if st.color and btn._ringEdges then
            btn._ringColor = st.color
        end
        UpdateSecure(btn, st.action)
        btn:Show()
        active[st.id] = true
        table.insert(shown, btn)
    end
    for id, btn in pairs(buttons) do
        if not active[id] then
            if not InCombat() then
                btn:Hide()
                btn:ClearAllPoints()
                btn:SetAttribute("type", nil); btn:SetAttribute("spell", nil)
                btn:SetAttribute("macrotext", nil); btn:SetAttribute("item", nil)
                btn._action = nil
                buttons[id] = nil
                table.insert(pool, btn)
            else
                pendingSecure = true
            end
        end
    end
    Layout(shown)
    ApplyVisuals()
    if #shown > 0 then root:Show() else root:Hide() end
end

function ns.Refresh()
    if not DB then return end
    if InCombat() then pendingSecure = true; return end
    ApplyStates(BuildButtonStates())
end
local Refresh = ns.Refresh

--------------------------------------------------------------------------------
-- Onboarding (lightweight, WoW-authentic, re-openable)
--------------------------------------------------------------------------------
local onboard
local function DismissOnboarding(markDone)
    if not DB then return end
    DB.onboardingDismissed = true
    if markDone then DB.onboardingDone = true; DB.firstRun = false end
    if onboard and onboard.Hide then onboard:Hide() end
end

local function ShowOnboarding(force)
    if not DB then return end
    if not force and (DB.onboardingDone or DB.onboardingDismissed) then return end
    if InCombat() then pendingSecure = true; return end
    if not onboard then
        onboard = CreateFrame("Frame", ADDON_NAME .. "Onboard", UIParent, "BackdropTemplate")
        onboard:SetSize(440, 265)
        onboard:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
        onboard:SetFrameStrata("DIALOG")
        onboard:SetClampedToScreen(true)
        onboard:EnableMouse(true)
        onboard:SetMovable(true)
        onboard:RegisterForDrag("LeftButton")
        onboard:SetScript("OnDragStart", function(self) if not InCombat() then self:StartMoving() end end)
        onboard:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        if onboard.SetBackdrop then
            onboard:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true, tileSize = 32, edgeSize = 32,
                insets = { left = 11, right = 12, top = 12, bottom = 11 }
            })
        else
            local bg = onboard:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(true)
            bg:SetColorTexture(0, 0, 0, 0.85)
        end
        local title = onboard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -18)
        title:SetText("|cff4dd0e6WoW Forever Fishing Addon ByJTT|r")
        onboard.title = title
        local body = onboard:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        body:SetPoint("TOPLEFT", 22, -54)
        body:SetPoint("TOPRIGHT", -22, -54)
        body:SetJustifyH("LEFT")
        body:SetJustifyV("TOP")
        onboard.body = body
        local by = onboard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        by:SetPoint("TOP", title, "BOTTOM", 0, -2)
        by:SetText("|cffaaaaaaby ByJTT · " .. (ByJTT.Brand.web or "byjtt.com") .. "|r")
        onboard.by = by
        local function mkBtn(text, x, y, w, onClick)
            local b = CreateFrame("Button", nil, onboard, "UIPanelButtonTemplate")
            b:SetSize(w or 120, 22)
            b:SetPoint("BOTTOM", onboard, "BOTTOM", x, y)
            b:SetText(text)
            b:SetScript("OnClick", onClick)
            return b
        end
        mkBtn("Got it", 0, 16, 110, function() DismissOnboarding(true); Print("You're set. Click Fish to cast. /ffish config for settings.") end)
        mkBtn("Open Settings", -125, 16, 110, function() DismissOnboarding(true); ns.OpenOptions() end)
        mkBtn("Later", 125, 16, 70, function() DismissOnboarding(false) end)
    end
    onboard.body:SetText(
        "One-click fishing with lure helpers, bite alert and a catch tracker.\n\n" ..
        "• Click |cff00ff00Fish|r to cast. |cff888888Shift+Drag|r to move (or unlock via /ffish).\n" ..
        "• Click |cff00ff00Lure|r when it appears to re-apply your best lure.\n" ..
        "• Catches are tracked per session and per zone (/ffish stats).\n\n" ..
        "Support: " .. (ByJTT.Brand.supportLabel or "Buy Me a Coffee") .. " (placeholder) — " .. (ByJTT.Brand.support or "") .. "\n" ..
        "Use |cff4dd0e6/ffish config|r for settings."
    )
    onboard:Show()
end
ns.ShowOnboarding = ShowOnboarding

--------------------------------------------------------------------------------
-- Settings UI (Blizzard-native when available; feature-detected)
--------------------------------------------------------------------------------
local optionsPanel
local function EnsureOptionsPanel()
    if optionsPanel then return optionsPanel end
    local panel = CreateFrame("Frame", ADDON_NAME .. "OptionsPanel", UIParent)
    panel.name = DISPLAY_NAME
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("|cff4dd0e6WoW Forever Fishing Addon|r |cffaaaaaaby ByJTT|r")
    local sub = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    sub:SetText("One-click fishing, lure & pole helpers, bite alert + catch tracker. /ffish help")

    local y = -60
    local function mkCheck(label, get, set, tooltip)
        local cb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 16, y)
        cb.Text:SetText(label)
        cb:SetScript("OnShow", function(self) self:SetChecked(get() and true or false) end)
        cb:SetScript("OnClick", function(self) set(self:GetChecked() and true or false) end)
        if tooltip then cb.tooltipText = label; cb.tooltipRequirement = tooltip end
        y = y - 26
        return cb
    end

    mkCheck("Lock position", function() return DB.locked end, function(v) DB.locked = v; Print("Locked: " .. tostring(v)) end,
        "When locked, Shift+Drag moves the buttons.")
    mkCheck("Pulse buttons", function() return DB.pulse end, function(v) DB.pulse = v end)
    mkCheck("Bite alert (sound + flash)", function() return DB.biteAlert end, function(v) DB.biteAlert = v; Refresh() end)
    mkCheck("Play sounds", function() return DB.sound end, function(v) DB.sound = v end)
    mkCheck("Debug logging", function() return DB.debug end, function(v) DB.debug = v end)

    local scaleLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scaleLabel:SetPoint("TOPLEFT", 20, y - 4); scaleLabel:SetText("Scale")
    local slider = CreateFrame("Slider", ADDON_NAME .. "ScaleSlider", panel, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 80, y)
    slider:SetMinMaxValues(0.6, 2.0); slider:SetValueStep(0.05); slider:SetObeyStepOnDrag(true)
    if slider.Low then slider.Low:SetText("0.6") end
    if slider.High then slider.High:SetText("2.0") end
    if slider.Text then slider.Text:SetText("") end
    slider:SetScript("OnShow", function(self) self:SetValue(DB.scale or 1.0) end)
    slider:SetScript("OnValueChanged", function(self, v) DB.scale = math.floor(v * 100 + 0.5) / 100; ApplyVisuals() end)
    y = y - 46

    local testBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testBtn:SetSize(120, 22); testBtn:SetPoint("TOPLEFT", 16, y); testBtn:SetText("Toggle Test")
    testBtn:SetScript("OnClick", function() Print("Test: use /ffish test to simulate bite flash."); flashUntil = 2; PlayBiteHint() end)
    local onbBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    onbBtn:SetSize(140, 22); onbBtn:SetPoint("LEFT", testBtn, "RIGHT", 8, 0); onbBtn:SetText("Show Onboarding")
    onbBtn:SetScript("OnClick", function() DB.onboardingDone = false; DB.onboardingDismissed = false; ShowOnboarding(true) end)
    local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetBtn:SetSize(120, 22); resetBtn:SetPoint("LEFT", onbBtn, "RIGHT", 8, 0); resetBtn:SetText("Reset Position")
    resetBtn:SetScript("OnClick", function() DB.point, DB.relPoint, DB.x, DB.y = "CENTER", "CENTER", 0, -190; ApplyPosition(); Print("Position reset.") end)
    local trackerBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    trackerBtn:SetSize(140, 22); trackerBtn:SetPoint("TOPLEFT", 16, y - 32); trackerBtn:SetText("Session Stats")
    trackerBtn:SetScript("OnClick", function() ns.PrintStats() end)
    y = y - 68

    -- About / Support (ByJTT foundation branding)
    local about = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    about:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 14)
    about:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 14)
    about:SetJustifyH("LEFT")
    about:SetText("|cff888888" .. DISPLAY_NAME .. " · v" .. VERSION .. " · by " .. (ByJTT.Brand.name or "ByJTT") ..
        " · " .. (ByJTT.Brand.web or "") .. " · " .. (ByJTT.Brand.github or "") ..
        "\nSupport (placeholder): " .. (ByJTT.Brand.support or "") .. "|r")

    optionsPanel = panel
    local registered = false
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local ok, cat = pcall(Settings.RegisterCanvasLayoutCategory, panel, panel.name)
        if ok and cat then
            cat.ID = panel.name
            pcall(Settings.RegisterAddOnCategory, cat)
            panel._settingsCategory = cat
            registered = true
        end
    end
    if not registered and InterfaceOptions_AddCategory then
        pcall(InterfaceOptions_AddCategory, panel)
        registered = true
    end
    panel._registered = registered
    return panel
end

function ns.OpenOptions()
    local p = EnsureOptionsPanel()
    if Settings and Settings.OpenToCategory and p and p._settingsCategory then
        pcall(Settings.OpenToCategory, p._settingsCategory.ID or p._settingsCategory)
        return
    end
    if InterfaceOptionsFrame_OpenToCategory and p then
        InterfaceOptionsFrame_OpenToCategory(p)
        InterfaceOptionsFrame_OpenToCategory(p)
        return
    end
    if p then p:Show(); Print("Options panel opened (fallback).") else Print("Options UI not available; use /ffish commands.") end
end

--------------------------------------------------------------------------------
-- Stats output
--------------------------------------------------------------------------------
function ns.PrintStats()
    local s = EnsureSession()
    local total = 0
    for _, c in pairs(DB.catches) do total = total + c end
    Print(string.format("Session: %d casts, %d catches (started %s)", sessionCasts, sessionCatches,
        date("%H:%M", s.started or time())))
    local skill = PlayerFishingSkill()
    if skill then Print("Fishing skill: " .. tostring(skill)) end
    local lureCount, bestLure = ItemCountAny(LURES)
    if bestLure then
        Print("Best lure in bags: " .. (bestLure.name or "?") .. " x" .. tostring(lureCount))
    else
        Print("No lures in bags.")
    end
    local zone = CurrentZoneName()
    Print("Zone: " .. tostring(zone) .. " — this session's zone catches:")
    local zc = DB.zones[zone]
    if zc then
        local names = {}
        for n in pairs(zc) do table.insert(names, n) end
        table.sort(names)
        for _, n in ipairs(names) do
            Print("  " .. tostring(n) .. " x" .. tostring(zc[n]))
        end
    else
        Print("  (none yet)")
    end
    Print("Lifetime catches: " .. tostring(total) .. " — /ffish zones for the zone breakdown.")
end

local function PrintZones()
    local zones = {}
    for z in pairs(DB.zones) do table.insert(zones, z) end
    table.sort(zones)
    if #zones == 0 then Print("No catches tracked yet. Go fish!"); return end
    for _, z in ipairs(zones) do
        local total, topName, topN = 0, nil, 0
        local names = {}
        for n, c in pairs(DB.zones[z]) do
            total = total + c
            table.insert(names, n)
            if c > topN then topName, topN = n, c end
        end
        Print(string.format("%s: %d caught (top: %s x%d)", tostring(z), total, tostring(topName), topN))
        table.sort(names)
        for _, n in ipairs(names) do
            Print("  " .. tostring(n) .. " x" .. tostring(DB.zones[z][n]))
        end
    end
end

--------------------------------------------------------------------------------
-- Events / init: bite detection + loot tracking
--------------------------------------------------------------------------------
local function OnBite()
    flashUntil = 2.5
    DB.lastBiteAt = time()
    PlayBiteHint()
    local btn = buttons["cast"]
    if btn and btn:IsShown() then
        -- brief visual emphasis handled by OnUpdate flash
    end
    Debug("bite detected")
end

local function Init()
    EnsureDB()
    MigrateDB()
    ApplyPosition(); ApplyVisuals()
    EnsureOptionsPanel()
    Refresh()
    Print("v" .. VERSION .. " ready. " .. DISPLAY_NAME .. " · " .. (ByJTT.Brand.web or "byjtt.com") .. " · |cff4dd0e6/ffish config|r")
    if not DB.onboardingDone and not DB.onboardingDismissed then
        if C_Timer and C_Timer.After then
            C_Timer.After(1.5, function() if DB and not DB.onboardingDone and not DB.onboardingDismissed then ShowOnboarding(false) end end)
        else
            ShowOnboarding(false)
        end
    end
end

root:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
    if event == "PLAYER_LOGIN" then
        Init()
    elseif event == "PLAYER_LOGOUT" or event == "PLAYER_LEAVING_WORLD" or event == "PLAYER_QUITING" then
        if DB then EndSession() end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if DB and pendingSecure then Refresh() end
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        if arg1 == "player" then
            fishingActive = true
            sessionCasts = sessionCasts + 1
            if DB.session then DB.session.casts = sessionCasts end
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED"
        or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_SUCCEEDED" then
        if arg1 == "player" then fishingActive = false end
    elseif event == "CHAT_MSG_LOOT" then
        -- "You receive loot: [item]xN" — only count the player's own loot while fishing.
        local text = arg1 or ""
        if text:find("^You receive loot:") or text:find("^You receive item:") then
            local link = text:match("(|Hitem:.-|h%[.-%]|h)")
            local qty = tonumber(text:match("|h%[.-%]|hx(%d+)")) or 1
            if link then RecordLoot(link, qty) end
        end
    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" or event == "CHAT_MSG_SPELL_SELF_BUFF" then
        -- classic bite cue lives in the float text; UNIT_SPELLCAST_EVENTS cover most cases.
    elseif event == "SPELLS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        if DB then Refresh() end
    elseif DB then
        Refresh()
    end
end)

-- Bite detection: the classic reliable cue is the bobber splash — without a
-- dedicated event we listen for the "fish bites" emote + channel state.
root:RegisterEvent("PLAYER_LOGIN")
root:RegisterEvent("PLAYER_ENTERING_WORLD")
root:RegisterEvent("SPELLS_CHANGED")
root:RegisterEvent("PLAYER_REGEN_ENABLED")
root:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
root:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
root:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
root:RegisterEvent("UNIT_SPELLCAST_FAILED")
root:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
root:RegisterEvent("CHAT_MSG_LOOT")
root:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
pcall(root.RegisterEvent, root, "PLAYER_LOGOUT")
pcall(root.RegisterEvent, root, "PLAYER_LEAVING_WORLD")

-- Emote handler second registration path (bite emote "The fish bites!")
local emoteFrame = CreateFrame("Frame")
emoteFrame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
emoteFrame:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
emoteFrame:SetScript("OnEvent", function(_, _, text)
    if type(text) == "string" then
        local lower = text:lower()
        if lower:find("bites") or lower:find("splash") then
            if fishingActive then OnBite() end
        end
    end
end)

--------------------------------------------------------------------------------
-- Slash commands (/ffish). Slash parity with settings.
--------------------------------------------------------------------------------
local function Help()
    Print(DISPLAY_NAME .. " — commands:")
    print("  /ffish config              open settings (WoW UI)")
    print("  /ffish cast                cast fishing now")
    print("  /ffish lure                apply best lure in bags")
    print("  /ffish stats               session + zone summary")
    print("  /ffish zones               full zone breakdown")
    print("  /ffish reset              end session, start fresh counters")
    print("  /ffish lock | unlock       lock/unlock position (Shift+Drag moves)")
    print("  /ffish move                show & unlock to reposition")
    print("  /ffish scale <0.6-2.0>     button scale")
    print("  /ffish bite                toggle bite alert")
    print("  /ffish test                flash bite alert (test)")
    print("  /ffish debug               status / tracker state")
    print("  /ffish onboarding          show onboarding")
    print("  /ffish rl                  reload UI")
end

SLASH_FOREVERFISHING1 = "/ffish"
SLASH_FOREVERFISHING2 = "/foreverfishing"
SlashCmdList.FOREVERFISHING = function(msg)
    msg = (msg or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")
    cmd = (cmd or ""):lower()
    if not DB then Print("not ready yet (try after login). /reload if needed."); return end

    if cmd == "" or cmd == "help" or cmd == "?" then
        Help()
    elseif cmd == "config" or cmd == "options" or cmd == "settings" or cmd == "ui" then
        ns.OpenOptions()
    elseif cmd == "onboarding" or cmd == "welcome" then
        DB.onboardingDone = false; DB.onboardingDismissed = false; ShowOnboarding(true)
    elseif cmd == "lock" then
        DB.locked = true; Print("Locked. (Shift+Drag still moves.)"); Refresh()
    elseif cmd == "unlock" or cmd == "move" then
        DB.locked = false
        Print("Unlocked - drag buttons (Shift+Drag) to move, then /ffish lock."); Refresh()
    elseif cmd == "cast" or cmd == "fish" then
        local spell = FishingSpellName()
        if CastSpellByName then CastSpellByName(spell); Print("Casting " .. spell .. "...")
        else Print("Cast unavailable.") end
    elseif cmd == "lure" then
        local _, best = ItemCountAny(LURES)
        if best and UseItemByName then
            UseItemByName(best.name or best.id)
            Print("Applying " .. (best.name or "lure") .. "...")
        elseif best then
            Print("Best lure: " .. (best.name or "?") .. " — click the Lure button.")
        else
            Print("No lures in bags.")
        end
    elseif cmd == "stats" then
        ns.PrintStats()
    elseif cmd == "zones" then
        PrintZones()
    elseif cmd == "reset" then
        EndSession(); EnsureSession()
        Print("Session reset. Tight lines!")
    elseif cmd == "scale" then
        local n = tonumber(rest)
        if n then DB.scale = math.max(0.6, math.min(2.0, n)); ApplyVisuals(); Print("Scale: " .. string.format("%.2f", DB.scale))
        else Print("Usage: /ffish scale 1.0") end
    elseif cmd == "bite" then
        DB.biteAlert = not DB.biteAlert; Print("Bite alert: " .. (DB.biteAlert and "ON" or "OFF"))
    elseif cmd == "test" then
        OnBite(); Print("Bite alert test.")
    elseif cmd == "debug" then
        local skill = PlayerFishingSkill()
        Print(string.format("v%s schema=%s combat=%s locked=%s skill=%s casts=%d catches=%d zone=%s",
            VERSION, tostring(DB._schema), tostring(InCombat()), tostring(DB.locked),
            tostring(skill), sessionCasts, sessionCatches, tostring(CurrentZoneName())))
        local lureCount, best = ItemCountAny(LURES)
        Print("lures: " .. (best and ((best.name or "?") .. " x" .. tostring(lureCount)) or "none"))
        local names = {}
        for n in pairs(DB.catches) do table.insert(names, n) end
        table.sort(names)
        local total = 0
        for _, n in ipairs(names) do total = total + DB.catches[n] end
        Print("lifetime catches: " .. tostring(total) .. " across " .. tostring(#names) .. " item(s)")
    elseif cmd == "rl" or cmd == "reload" then
        ReloadUI()
    else
        Print("Unknown command. Try /ffish help")
    end
end
