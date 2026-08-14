---@class LUI
local LUI = select(2, ...)

BINDING_HEADER_LUI = format("|cffffccff%s|r", "LavUI")

local ACTION_BARS = {
    "bar1", "bar3", "bar4", "bar5", "bar6", "bar13", "bar14", "bar15", "barPet"
}

--- Toggle the mouseover state of the (default) hidden action bars.
function LUI:ToggleBars()
    if not ElvUI then return end
    local E = unpack(ElvUI)

    local mouseover = E.db.actionbar.bar1.mouseover
    for _, bar in pairs(ACTION_BARS) do
        if E.db.actionbar[bar] then
            E.db.actionbar[bar].mouseover = not mouseover

            if bar == "barPet" then
                E.ActionBars:PositionAndSizeBarPet()
            else
                E.ActionBars:PositionAndSizeBar(bar)
            end
        end
    end
end

BINDING_NAME_LUITOGGLEBARS = "Toggle ActionBar Visibility"

--- Toggle the right chat panel and Details windows. Sorta like the old AddOnSkins functionality.
---
--- Prefers our own panel, falling back to the AtrocityEssentials fork's second
--- panel so the binding keeps working on either. Ours needs the module to do
--- the hiding rather than the frame: our chat window is parented to UIParent,
--- not to the panel, so hiding the panel alone would leave the text behind.
---@param hide? boolean desired state of the chat panel. If nil, it will toggle the current state.
function LUI:TogglePanel(hide)
    ---@class ChatPanel
    local ChatPanel = self:GetModule("ChatPanel", true)
    local ours = ChatPanel and ChatPanel.panel
    local panel = ours or _G["AE_ChatPanel2"]

    if not EllesmereUI or not panel or not _G["_EDM_DB"] then return end

    local dmCfg = _G["_EDM_DB"].profile.dm

    if hide == nil then return self:TogglePanel(panel:IsShown()) end

    if ours then
        ChatPanel:SetShown(not hide)
    elseif hide then
        panel:Hide()
    else
        panel:Show()
    end

    dmCfg.visibility = hide and "always" or "never"
    EllesmereUI.RequestVisibilityUpdate()
end

BINDING_NAME_LUITOGGLEPANEL = "Toggle Right Panel"
