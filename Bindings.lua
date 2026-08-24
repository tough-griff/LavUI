---@class LUI
local LUI = select(2, ...)

BINDING_HEADER_LUI = format("|cffffccff%s|r", "LavUI")

local ACTION_BARS = { "MainBar", "Bar2", "Bar3", "Bar4", "Bar5", "PetBar" }

--- Toggle the mouseover state of the (default) hidden action bars.
function LUI:ToggleBars()
    if not EllesmereUI or not EllesmereUI.Lite then return end

    local EAB = EllesmereUI.Lite.GetAddon("EllesmereUIActionBars", true)
    if not EAB or not EAB.db or not EAB.VisibilityCompat then return end

    local bars = EAB.db.profile.bars
    local mouseover = bars.MainBar and bars.MainBar.mouseoverEnabled
    local mode = mouseover and "always" or "mouseover"

    for _, bar in pairs(ACTION_BARS) do
        if bars[bar] then
            EAB.VisibilityCompat.ApplyMode(bars[bar], mode)
        end
    end

    EAB:RefreshRuntimeVisibility()
    EAB:RefreshMouseover()
    EAB:ApplyCombatVisibility()
end

BINDING_NAME_LUITOGGLEBARS = "Toggle ActionBar Visibility"

--- Toggle the right chat panel and damage meter windows. See ChatPanel:TogglePanel --
--- kept here as a thin delegator since the keybinding calls this name.
---@param hide? boolean desired state of the chat panel. If nil, it will toggle the current state.
function LUI:TogglePanel(hide)
    ---@class ChatPanel
    local ChatPanel = self:GetModule("ChatPanel", true)
    if not ChatPanel then return end
    return ChatPanel:TogglePanel(hide)
end

BINDING_NAME_LUITOGGLEPANEL = "Toggle Right Panel"
