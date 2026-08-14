---@class LUI
local LUI = select(2, ...)
---@class ChatPanel: AceModule, AceEvent-3.0, AceHook-3.0
local ChatPanel = LUI:NewModule("ChatPanel", "AceEvent-3.0", "AceHook-3.0")

-- A SECOND CHAT PANEL, FROM OUTSIDE ATROCITYESSENTIALS
--
-- AES seats exactly one chat window in its own panel; GeneralDockManager is a
-- game singleton and belongs to that one. This gives a second, UNDOCKED window
-- the same treatment from our side of the fence: same size, same backdrop,
-- same tab styling, plus an EllesmereUI mover.
--
-- Nothing here re-implements the skin. SetupChat loops every frame in
-- CHAT_FRAMES, so fonts, tab textures, timestamps and the copy button already
-- reach our window for free -- and every measurement and colour below is read
-- back out of AES rather than duplicated, so the two panels cannot drift.
--
-- AES touches a window it does not own in exactly two places, and both are
-- worked AROUND rather than fought:
--
--   1. UpdateChatTab does `chat:SetParent(UIParent)` for every frame. So we
--      never reparent -- we anchor with SetPoint and leave the parent alone.
--      Anchors are independent of parent, so its write becomes a no-op.
--   2. PositionChat re-shows Blizzard's dark `chat.Background` on anything
--      undocked, and the flag is sticky in both directions. So we use
--      SetAlpha(0) instead of Hide -- AES only ever calls Show/Hide there, so
--      the two never collide.
--
-- It sets no position and no size for a window it does not own, which is what
-- makes this viable at all. None of that is a supported API; if AES changes
-- either behaviour this shows up as a visual bug, not an error.

local PANEL_NAME = "LavUI_ChatPanel"
local BACKDROP_NAME = "LavUI_ChatPanelBackdrop"
local TAB_BACKDROP_NAME = "LavUI_ChatPanelTabBackdrop"

-- Lifted from AES so the two panels line up pixel for pixel. Only used as
-- fallbacks for the sizes, which are read live from its db.
local PANEL_FRAME_LEVEL = 300
local PANEL_WIDTH = 450
local PANEL_HEIGHT = 250
local BASE_OFFSET = 35
local PADDING = 5
local H_PADDING = 5
local TAB_HEIGHT = 22

local BACKDROP_TEMPLATE = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
}

-- Geometry drifts by fractions of a pixel through scale maths; only a real
-- move should trigger a write.
local EPSILON = 0.5
local WATCH_INTERVAL = 0.5

---@return table
function ChatPanel:GetConfig()
    return LUI.db.global.chatPanel
end

--- The AES Chat module, if that addon is loaded. Ace3 registers addons
--- globally, so this needs nothing exposed on their side.
---@return table? module
function ChatPanel:GetAES()
    local ace = LibStub("AceAddon-3.0"):GetAddon("atrocityEssentials", true)
    return ace and ace:GetModule("Chat", true) or nil
end

--- AES's live Chat profile. Re-read every time rather than cached -- a profile
--- switch hands back a different table.
---@return table? db
function ChatPanel:GetAESDB()
    local aes = self:GetAES()
    return aes and aes.db or nil
end

--- Is AES already seating this window in one of ITS panels? Two addons
--- writing geometry to one frame is a fight neither wins.
---@param chat Frame
---@return boolean
function ChatPanel:IsClaimedByAES(chat)
    local aes = self:GetAES()
    if not aes then return false end

    -- Upstream keeps a single seat; the two-panel fork keeps a list. Check
    -- both so this behaves either way.
    if aes.ChatWindow == chat then return true end
    if type(aes.panels) == "table" then
        for _, panel in pairs(aes.panels) do
            if panel and panel.chatWindow == chat then return true end
        end
    end

    return false
end

--- The window we are seating, or nil with a reason when it is not usable.
---@return Frame? chat
---@return string? reason
function ChatPanel:GetChatFrame()
    local id = self:GetConfig().frameID
    local chat = id and _G["ChatFrame" .. id]
    if not chat then return nil, format("ChatFrame%s does not exist", tostring(id)) end

    -- The combat log carries its own quick-button bar and AES excludes it from
    -- styling outright, so it would need geometry we are not writing.
    if IsCombatLog and IsCombatLog(chat) then return nil, "the combat log is not supported" end
    if chat.isDocked then return nil, format("ChatFrame%d is docked -- undock it first", id) end
    if self:IsClaimedByAES(chat) then return nil, format("ChatFrame%d is already seated by AtrocityEssentials", id) end

    return chat
end

--- Panel size, matching AES's own panel. Read live so resizing theirs resizes
--- ours on the next pass.
---@return number width
---@return number height
function ChatPanel:GetPanelSize()
    local db = self:GetAESDB()
    if not db then return PANEL_WIDTH, PANEL_HEIGHT end
    return db.Width or PANEL_WIDTH, db.Height or PANEL_HEIGHT
end

--- Where the seated window belongs inside the panel. Matches AES's own seat
--- maths so both windows inset identically.
---@return number width
---@return number height
function ChatPanel:GetSeatSize()
    local width, height = self:GetPanelSize()
    return width - (H_PADDING * 2), height - BASE_OFFSET
end

function ChatPanel:CreatePanel()
    if self.panel then return self.panel end

    -- BACKGROUND strata deliberately: the chat frame stays parented to
    -- UIParent at its own strata, so the panel has to sit behind it rather
    -- than rely on the parent/child ordering AES gets for its own seat.
    local panel = CreateFrame("Frame", PANEL_NAME, UIParent)
    panel:SetFrameStrata("BACKGROUND")
    panel:SetFrameLevel(PANEL_FRAME_LEVEL)
    panel:SetClampedToScreen(true)

    local backdrop = CreateFrame("Frame", BACKDROP_NAME, panel, "BackdropTemplate")
    backdrop:SetFrameLevel(panel:GetFrameLevel() - 1)
    backdrop:SetAllPoints(panel)

    local tabBackdrop = CreateFrame("Frame", TAB_BACKDROP_NAME, panel, "BackdropTemplate")
    tabBackdrop:SetFrameLevel(panel:GetFrameLevel() + 1)

    self.panel = panel
    self.backdrop = backdrop
    self.tabBackdrop = tabBackdrop

    self:UpdatePanel()
    return panel
end

--- Size, position and backdrop of the panel itself. Every colour and size
--- comes from AES, so this is also what picks up their options changes.
function ChatPanel:UpdatePanel()
    if not self.panel then return end

    local cfg = self:GetConfig()
    local db = self:GetAESDB()

    self.panel:SetSize(self:GetPanelSize())
    self.panel:ClearAllPoints()
    self.panel:SetPoint(cfg.anchorFrom, UIParent, cfg.anchorTo, cfg.xOffset, cfg.yOffset)

    local backdrop = db and db.Backdrop
    local color = backdrop and backdrop.Color or { 0, 0, 0, 0.8 }
    local border = backdrop and backdrop.BorderColor or { 0, 0, 0, 1 }

    self.backdrop:SetBackdrop(BACKDROP_TEMPLATE)
    if not backdrop or backdrop.Enabled ~= false then
        self.backdrop:SetBackdropColor(color[1], color[2], color[3], color[4] or 0.8)
        self.backdrop:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1)
    else
        self.backdrop:SetBackdropColor(0, 0, 0, 0)
        self.backdrop:SetBackdropBorderColor(0, 0, 0, 0)
    end

    local tabDB = db and db.TabBackdrop
    local tabColor = tabDB and tabDB.Color or { 0, 0, 0, 0.2 }
    local tabBorder = tabDB and tabDB.BorderColor or { 0, 0, 0, 1 }

    self.tabBackdrop:ClearAllPoints()
    self.tabBackdrop:SetPoint("TOPLEFT", self.panel, "TOPLEFT", 0, 0)
    self.tabBackdrop:SetPoint("BOTTOMRIGHT", self.panel, "TOPRIGHT", 0, -TAB_HEIGHT)
    self.tabBackdrop:SetBackdrop(BACKDROP_TEMPLATE)

    if not tabDB or tabDB.Enabled then
        self.tabBackdrop:SetBackdropColor(tabColor[1], tabColor[2], tabColor[3], tabColor[4] or 0.2)
        self.tabBackdrop:SetBackdropBorderColor(tabBorder[1], tabBorder[2], tabBorder[3], tabBorder[4] or 1)
        self.tabBackdrop:Show()
    else
        self.tabBackdrop:Hide()
    end

    self:Reseat(true)
end

--- True when the window is not where we put it. Compare BEFORE writing, so
--- the watcher costs a few subtractions in the common case.
---@param chat Frame
---@return boolean
function ChatPanel:NeedsReseat(chat)
    local wantW, wantH = self:GetSeatSize()
    if abs(chat:GetWidth() - wantW) > EPSILON or abs(chat:GetHeight() - wantH) > EPSILON then
        return true
    end

    local panelLeft, panelBottom = self.panel:GetLeft(), self.panel:GetBottom()
    local left, bottom = chat:GetLeft(), chat:GetBottom()
    -- An unrendered frame reports nil rather than 0; nothing to compare
    -- against, so leave it until it has a rect.
    if not (panelLeft and panelBottom and left and bottom) then return false end

    return abs(left - (panelLeft + H_PADDING)) > EPSILON
        or abs(bottom - (panelBottom + PADDING)) > EPSILON
end

--- Put the window in the panel. Safe to call repeatedly; it writes only when
--- something has actually moved.
---@param force? boolean skip the compare and write regardless
function ChatPanel:Reseat(force)
    if not self.panel then return end

    local chat, reason = self:GetChatFrame()
    self.blockedReason = reason
    if not chat then return end

    -- Chat frames are unprotected, but AES defers its own positioning in
    -- combat and there is nothing here worth racing it for.
    if LUI:InCombat() then
        self.pendingReseat = true
        return
    end

    -- From here on we have touched this window, so remember WHICH -- Release
    -- has to undo exactly what we did and nothing else.
    self:CaptureState(chat)
    self.seated = chat

    -- Blizzard's dark background, killed by ALPHA rather than Hide: AES
    -- re-shows this on anything undocked and makes the flag sticky, so hiding
    -- it would be a fight. Nothing writes alpha on it.
    local background = chat.Background
    if background and background:GetAlpha() ~= 0 then background:SetAlpha(0) end

    -- Only on a forced pass. The watcher runs twice a second, and rewriting
    -- the tab text on every tick would be churn at best and a flicker at
    -- worst -- Blizzard-driven repaints are caught by the hook instead.
    if force then self:StyleTab(chat) end

    if not force and not self:NeedsReseat(chat) then return end

    local width, height = self:GetSeatSize()
    chat:ClearAllPoints()
    chat:SetPoint("BOTTOMLEFT", self.panel, "BOTTOMLEFT", H_PADDING, PADDING)
    chat:SetSize(width, height)

    -- Marks the position as ours so Blizzard saves it rather than restoring
    -- over the top on the next load.
    if chat:IsMovable() then chat:SetUserPlaced(true) end

    -- The tab is anchored to the chat frame for an undocked window, so it
    -- follows the move on its own -- but AES reparents it to UIParent on every
    -- pass, so re-assert Blizzard's own anchor rather than trusting it.
    if FCF_SetTabPosition then FCF_SetTabPosition(chat, 0) end
end

-- THE TAB NAME, COLOURED AS THE ACTIVE TAB
--
-- AES's OnFCFTab_UpdateColors branches entirely on `selected`, and Blizzard
-- only ever sets that for DOCKED tabs -- it comes from the dock's own
-- selection. An undocked window is nobody's selection, so its tab falls
-- through to the grey unselected TabTextColor forever while the docked primary
-- gets the selector arrows and the selected text colour.
--
-- Rather than reproduce any of that, re-run THEIR method with selected forced
-- true. Every option they expose -- selector style, selector colour, selected
-- text colour, class colouring for whispers -- lands exactly as it does on the
-- docked tab, and keeps working when they change it.
---@param chat Frame
function ChatPanel:StyleTab(chat)
    local aes = self:GetAES()
    if not (aes and aes.OnFCFTab_UpdateColors) then return end

    local tab = _G["ChatFrame" .. chat:GetID() .. "Tab"]
    if not tab then return end

    aes:OnFCFTab_UpdateColors(tab, true)
end

-- SHOW/HIDE FOR THE TOGGLE BINDING
--
-- The window is parented to UIParent rather than to the panel -- see the note
-- at the top -- so hiding the panel would leave the chat text floating over
-- nothing. Both have to be taken down together.
--
-- ALPHA rather than Hide on the chat frame, deliberately: Blizzard persists a
-- window's shown state, and a hidden undocked window can come back gone after
-- a reload. Alpha touches nothing it saves. The tab is the other way round --
-- AES pins tab alpha to 1 when Keep Tabs Opaque is on, so writing alpha there
-- would be a fight, while nothing re-shows an undocked tab.
---@param shown boolean
function ChatPanel:SetShown(shown)
    if not self.panel then return end

    self.panel:SetShown(shown)

    local chat = self:GetChatFrame()
    if not chat then return end

    chat:SetAlpha(shown and 1 or 0)
    chat:EnableMouse(shown)

    local tab = _G["ChatFrame" .. chat:GetID() .. "Tab"]
    if tab then tab:SetShown(shown) end
end

--- Where the window was before we first moved it this session. Captured once
--- per window, from Reseat, before anything is written.
---
--- Only as good as the session it was taken in: SetUserPlaced means Blizzard
--- reloads the window at OUR geometry, so after a reload this captures that
--- rather than anything Blizzard chose. Releasing then leaves the window where
--- the panel was instead of where it started. Deliberate -- the alternative is
--- FCF_RestorePositionAndDimensions, which errors on a non-movable frame and
--- taints the path into Blizzard's chat code. Drag or Edit Mode fixes it.
---@param chat Frame
function ChatPanel:CaptureState(chat)
    if self.original and self.original.frame == chat then return end

    -- Named fields rather than a packed table: GetPoint can hand back a nil
    -- relativeTo, and a table with a hole in it breaks both # and unpack.
    local point, relativeTo, relativePoint, x, y = chat:GetPoint()

    self.original = {
        frame = chat,
        point = point,
        relativeTo = relativeTo,
        relativePoint = relativePoint,
        x = x,
        y = y,
        width = chat:GetWidth(),
        height = chat:GetHeight(),
    }
end

-- HAND THE WINDOW BACK
--
-- Only ever the window we actually seated. An earlier cut resolved it by
-- config ID instead, which meant changing the dropdown "restored" a window we
-- had never touched -- and if that was a docked one or the combat log,
-- Blizzard's own restore hard-errored on it.
--
-- It restores our captured geometry rather than calling
-- FCF_RestorePositionAndDimensions, for the same reason: that calls
-- SetUserPlaced, which errors on any frame that is not movable or resizable,
-- and taints the path from us into Blizzard's chat code besides.
function ChatPanel:Release()
    local chat = self.seated
    if not chat then return end

    self.seated = nil

    if chat.Background then chat.Background:SetAlpha(1) end

    -- Undo a SetShown(false) that is still in effect, or the window comes back
    -- invisible and click-through with no sign of why.
    chat:SetAlpha(1)
    chat:EnableMouse(true)
    local tab = _G["ChatFrame" .. chat:GetID() .. "Tab"]
    if tab then tab:Show() end

    local original = self.original
    if not (original and original.frame == chat) then return end
    self.original = nil

    chat:SetSize(original.width, original.height)
    if original.point then
        chat:ClearAllPoints()
        chat:SetPoint(
            original.point,
            original.relativeTo or UIParent,
            original.relativePoint or original.point,
            original.x or 0,
            original.y or 0
        )
    end
end

function ChatPanel:StartWatcher()
    if self.watcher then return end

    -- Blizzard re-anchors chat frames from paths we do not see -- Edit Mode
    -- layout applies, FCF_RestorePositionAndDimensions on a zone change. AES
    -- solves the same problem the same way for its own seat.
    self.watcher = C_Timer.NewTicker(WATCH_INTERVAL, function()
        if self.panel and self.panel:IsShown() then self:Reseat() end
    end)
end

function ChatPanel:StopWatcher()
    if not self.watcher then return end
    self.watcher:Cancel()
    self.watcher = nil
end

--- Register the panel as an EllesmereUI unlock element, so it can be dragged
--- with everything else rather than needing its own mover. AES's Edit Mode
--- lives on its private namespace table and is not reachable from here, but
--- EllesmereUI is a global and takes registrations from anyone.
function ChatPanel:RegisterUnlockElement()
    if self.unlockRegistered then return end
    if not EllesmereUI or not EllesmereUI.RegisterUnlockElements then return end

    local element = {
        key = "LavUI_ChatPanel",
        label = "Chat Panel 2",
        group = "Chat",
        order = 602,
        noResize = true,

        getFrame = function() return self.panel end,
        getSize = function()
            if not self.panel then return nil end
            return self.panel:GetWidth(), self.panel:GetHeight()
        end,
        isHidden = function() return not (self:IsEnabled() and self.panel) end,

        savePos = function(_, point, relPoint, x, y)
            local cfg = self:GetConfig()
            cfg.anchorFrom, cfg.anchorTo, cfg.xOffset, cfg.yOffset = point, relPoint, x, y
            self:UpdatePanel()
        end,

        loadPos = function()
            if not self:IsEnabled() then return nil end
            local cfg = self:GetConfig()
            return { point = cfg.anchorFrom, relPoint = cfg.anchorTo, x = cfg.xOffset, y = cfg.yOffset }
        end,

        clearPos = function()
            -- No-op on purpose, same as AES does: our config always holds a
            -- usable anchor, and blanking it would leave the panel unplaced.
        end,

        applyPos = function() self:UpdatePanel() end,
    }

    local make = EllesmereUI.MakeUnlockElement
    EllesmereUI:RegisterUnlockElements({ make and make(element) or element }, "LavUI")
    self.unlockRegistered = true
end

function ChatPanel:PLAYER_ENTERING_WORLD()
    -- Deferred a frame: Blizzard restores its own chat geometry as part of the
    -- loading screen, and writing into the middle of that measures against
    -- numbers about to be overwritten.
    C_Timer.After(0, function() self:Reseat(true) end)
end

function ChatPanel:UPDATE_CHAT_WINDOWS()
    self:Reseat(true)
end

function ChatPanel:PLAYER_REGEN_ENABLED()
    if not self.pendingReseat then return end
    self.pendingReseat = nil
    self:Reseat(true)
end

function ChatPanel:OnInitialize()
    self:SetEnabledState(LUI.db.global.chatPanel.enabled)

    -- Registered even while the panel is off, because EllesmereUI takes
    -- registrations once and AES's own notes are explicit that a late one is
    -- never picked up. The element reports isHidden until we are enabled.
    -- Retried from OnEnable in case EUI had not loaded yet at this point.
    self:RegisterUnlockElement()
end

function ChatPanel:OnEnable()
    if not LUI.db.global.chatPanel.enabled then return end

    self:CreatePanel()
    self.panel:Show()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UPDATE_CHAT_WINDOWS")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")

    -- Runs AFTER any hook AES registered at load, so our tab keeps the
    -- selected treatment rather than being overwritten back to grey. Hooked
    -- once for the session -- a post-hook cannot be removed, so OnDisable
    -- leans on the IsEnabled check inside it instead.
    if not self.tabHooked and FCFTab_UpdateColors then
        hooksecurefunc("FCFTab_UpdateColors", function(tab, selected)
            if selected or not self:IsEnabled() then return end
            local chat = self:GetChatFrame()
            if chat and tab == _G["ChatFrame" .. chat:GetID() .. "Tab"] then self:StyleTab(chat) end
        end)
        self.tabHooked = true
    end

    self:StartWatcher()
    self:RegisterUnlockElement()
    self:Reseat(true)
end

function ChatPanel:OnDisable()
    self:StopWatcher()
    self:UnregisterAllEvents()
    self:Release()
    if self.panel then self.panel:Hide() end
end
