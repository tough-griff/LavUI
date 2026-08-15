---@class LUI
local LUI = select(2, ...)
---@class ChatSetup: AceModule
local ChatSetup = LUI:NewModule("ChatSetup")

-- Blizzard API compatibility (some FCF_* functions moved into ChatFrameUtil).
local ChatFrameUtil = _G.ChatFrameUtil
local FCF_OpenNewWindow = ChatFrameUtil and ChatFrameUtil.OpenNewWindow or FCF_OpenNewWindow
local FCF_ResetChatWindows = ChatFrameUtil and ChatFrameUtil.ResetChatWindows or FCF_ResetChatWindows
local FCF_SavePositionAndDimensions = ChatFrameUtil and ChatFrameUtil.SavePositionAndDimensions or FCF_SavePositionAndDimensions
local FCF_SetChatWindowFontSize = ChatFrameUtil and ChatFrameUtil.SetChatWindowFontSize or FCF_SetChatWindowFontSize
local FCF_SetWindowName = ChatFrameUtil and ChatFrameUtil.SetWindowName or FCF_SetWindowName
local FCF_StopDragging = ChatFrameUtil and ChatFrameUtil.StopDragging or FCF_StopDragging
local FCF_UnDockFrame = ChatFrameUtil and ChatFrameUtil.UnDockFrame or FCF_UnDockFrame
local FCFDock_SelectWindow = ChatFrameUtil and ChatFrameUtil.Dock_SelectWindow or FCFDock_SelectWindow

---@param frame ChatFrameMixin
---@param group string
local function AddMessageGroup(frame, group)
    if frame.AddMessageGroup then
        frame:AddMessageGroup(group)
    elseif ChatFrame_AddMessageGroup then
        ChatFrame_AddMessageGroup(frame, group)
    end
end

---@param frame ChatFrameMixin
local function RemoveAllMessageGroups(frame)
    if frame.RemoveAllMessageGroups then
        frame:RemoveAllMessageGroups()
    elseif ChatFrame_RemoveAllMessageGroups then
        ChatFrame_RemoveAllMessageGroups(frame)
    end
end

---@param frame ChatFrameMixin
---@param group string
local function RemoveMessageGroup(frame, group)
    if frame.RemoveMessageGroup then
        frame:RemoveMessageGroup(group)
    elseif ChatFrame_RemoveMessageGroup then
        ChatFrame_RemoveMessageGroup(frame, group)
    end
end

-- No ChatFrame_AddChannel fallback here, unlike its four siblings above:
-- Blizzard's Deprecated_ChatFrame.lua never aliased one. :AddChannel is the
-- only path that has ever existed.
---@param frame ChatFrameMixin
---@param channel string
local function AddChannel(frame, channel)
    if frame.AddChannel then
        frame:AddChannel(channel)
    end
end

---@param frame ChatFrameMixin
---@param channel string
local function RemoveChannel(frame, channel)
    if frame.RemoveChannel then
        frame:RemoveChannel(channel)
    elseif ChatFrame_RemoveChannel then
        ChatFrame_RemoveChannel(frame, channel)
    end
end

--- If Chat Panel 2 is already enabled, undock a chat window and seat it
--- there. Entirely a no-op -- doesn't even undock -- when the panel is off,
--- since turning it on is an explicit, opt-in choice made in Options.lua,
--- not something this flips on someone's behalf.
---@param id number ChatFrame index to seat
local function SeatInChatPanel(id)
    ---@class ChatPanel
    local ChatPanel = LUI:GetModule("ChatPanel", true)
    if not ChatPanel or not ChatPanel:IsEnabled() then return end

    local chat = _G["ChatFrame" .. id]
    if not chat then return end

    if chat.isDocked and FCF_UnDockFrame then
        FCF_UnDockFrame(chat)
    end

    LUI.db.global.chatPanel.frameID = id
    ChatPanel:Release()
    ChatPanel:UpdatePanel()
end

------------------------------------------------------------------------
-- Chat window setup, ported from AtrocityUI's SetupChat.
------------------------------------------------------------------------
function ChatSetup:Configure()
    -- CVars
    C_CVar.SetCVar("chatClassColorOverride", 0)
    C_CVar.SetCVar("colorChatNamesByClass", 1)
    C_CVar.SetCVar("chatMouseScroll", 1)
    C_CVar.SetCVar("chatStyle", "classic")
    C_CVar.SetCVar("whisperMode", "inline")
    C_CVar.SetCVar("wholeChatWindowClickable", 0)
    C_CVar.SetCVar("speechToText", 0)
    C_CVar.SetCVar("textToSpeech", 0)

    -- Reset to Blizzard defaults, then open the extra tabs this layout needs.
    FCF_ResetChatWindows()

    -- Enable class-colored names for all chat types
    if SetChatColorNameByClass then
        for _, group in next, {
            "SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER",
            "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT",
            "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER",
            "ACHIEVEMENT", "GUILD_ACHIEVEMENT",
            "CHANNEL1", "CHANNEL2", "CHANNEL3", "CHANNEL4", "CHANNEL5",
        } do
            SetChatColorNameByClass(group, true)
        end
    end

    -- Open new tabs
    FCF_OpenNewWindow() -- ChatFrame4: Trade
    FCF_OpenNewWindow() -- ChatFrame5: DMs
    FCF_OpenNewWindow() -- ChatFrame6: Guild
    FCF_OpenNewWindow() -- ChatFrame7: Spam

    for _, name in next, CHAT_FRAMES do
        local frame = _G[name]
        if frame then
            FCF_SetChatWindowFontSize(nil, frame, 16)
            FCF_SavePositionAndDimensions(frame)
            FCF_StopDragging(frame)
        end
    end

    -- Tab 1: General
    local general = _G.ChatFrame1
    AddMessageGroup(general, "TARGETICONS")
    RemoveMessageGroup(general, "COMBAT_XP_GAIN")
    RemoveMessageGroup(general, "COMBAT_HONOR_GAIN")
    RemoveMessageGroup(general, "COMBAT_FACTION_CHANGE")
    RemoveMessageGroup(general, "SKILL")
    RemoveMessageGroup(general, "LOOT")
    RemoveMessageGroup(general, "CURRENCY")
    RemoveMessageGroup(general, "MONEY")
    RemoveChannel(general, "General")
    RemoveChannel(general, "Trade")
    RemoveChannel(general, "Services")
    RemoveChannel(general, "LocalDefense")
    RemoveChannel(general, "LookingForGroup")

    -- Tab 2: Combat Log -- untouched
    local log = _G.ChatFrame2
    FCF_SetWindowName(log, "Log")

    -- Tab 3: Voice -- untouched

    -- Tab 4: Trade -- chat channels only, no message groups
    local trade = _G.ChatFrame4
    FCF_SetWindowName(trade, "Loot / Trade")
    RemoveAllMessageGroups(trade)
    AddMessageGroup(trade, "COMBAT_XP_GAIN")
    AddMessageGroup(trade, "COMBAT_HONOR_GAIN")
    AddMessageGroup(trade, "COMBAT_FACTION_CHANGE")
    AddMessageGroup(trade, "SKILL")
    AddMessageGroup(trade, "LOOT")
    AddMessageGroup(trade, "CURRENCY")
    AddMessageGroup(trade, "MONEY")
    AddChannel(trade, "Trade")
    AddChannel(trade, "Services")

    -- Tab 5: DMs -- all whisper-related groups
    local dms = _G.ChatFrame5
    FCF_SetWindowName(dms, "DMs")
    RemoveAllMessageGroups(dms)
    AddMessageGroup(dms, "WHISPER")
    AddMessageGroup(dms, "BN_WHISPER")

    -- Tab 6: Guild -- all guild-related groups
    local guild = _G.ChatFrame6
    FCF_SetWindowName(guild, "Guild")
    RemoveAllMessageGroups(guild)
    AddMessageGroup(guild, "GUILD")
    AddMessageGroup(guild, "OFFICER")
    AddMessageGroup(guild, "GUILD_ACHIEVEMENT")
    AddMessageGroup(guild, "GUILD_DISCORD")

    -- Tab 7: Spam
    local spam = _G.ChatFrame7
    FCF_SetWindowName(spam, "Spam")
    RemoveAllMessageGroups(spam)
    AddMessageGroup(spam, "CHANNEL")
    AddChannel(spam, "General")
    AddChannel(spam, "LocalDefense")
    AddChannel(spam, "LookingForGroup")

    if _G["GENERAL_CHAT_DOCK"] then
        FCFDock_SelectWindow(_G["GENERAL_CHAT_DOCK"], general)
    end

    -- Undock the Loot/Trade tab and hand it straight to Chat Panel 2 instead
    -- of leaving it floating loose in the middle of the screen.
    SeatInChatPanel(4)

    LUI:Print("Chat windows configured.")
end
