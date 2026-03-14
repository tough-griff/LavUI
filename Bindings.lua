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

--- Toggle the right chat panel and Details windows. Sorta like the old AddOnSkins
--- functionality.
---@param hide? boolean
function LUI:TogglePanel(hide)
    if not Details or not RightChatPanel then return end

    ---@type Frame
    local Panel = RightChatPanel
    if hide == true then
        Panel:Hide()
        Details:ReopenAllWindows()
    elseif hide == false then
        Panel:Show()
        Details:ShutDownAllInstances()
    else
        self:TogglePanel(Panel:IsShown())
    end
end

BINDING_NAME_LUITOGGLEPANEL = "Toggle Right Panel"
