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
