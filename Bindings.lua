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

--- Toggle the right chat panel and danage meter windows. Sorta like the old AddOnSkins functionality.
---@param hide? boolean desired state of the chat panel. If nil, it will toggle the current state.
function LUI:TogglePanel(hide)
    ---@class ChatPanel
    local ChatPanel = self:GetModule("ChatPanel", true)
    if not EllesmereUI or not ChatPanel.panel or not _G["_EDM_DB"] then return end

    local dmCfg = _G["_EDM_DB"].profile.dm

    if hide == nil then
        return self:TogglePanel(ChatPanel.panel:IsShown())
    elseif hide then
        ChatPanel:SetShown(false)
        dmCfg.visibility = "always"
    else
        ChatPanel:SetShown(true)
        dmCfg.visibility = "never"
    end

    EllesmereUI.RequestVisibilityUpdate()
end

BINDING_NAME_LUITOGGLEPANEL = "Toggle Right Panel"
