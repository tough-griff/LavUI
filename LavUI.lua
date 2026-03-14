local addon = select(2, ...)

---@class LUI: AceAddon, AceHook-3.0
local LUI = LibStub("AceAddon-3.0"):NewAddon(addon, "LavUI", "AceHook-3.0")
setglobal("LUI", LUI)

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

--- Add the 'classcolor:target' tag to ElvUI since they removed it but it still
--- seems to function just fine.
function LUI:AddElvUITags()
    if not ElvUI then return end
    local E = unpack(ElvUI)

    E:AddTag('classcolor:target', 'UNIT_TARGET', function(unit)
        local unitTarget = unit .. 'target'
        if UnitExists(unitTarget) then
            return _TAGS.classcolor(unitTarget)
        end
    end)
end

function LUI:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("LavUIDB", self:GetDefaults(), DEFAULT)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("LavUI", self:GetOptions())
    local _, category = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("LavUI")
    LibStub("AceConsole-3.0"):RegisterChatCommand("lui", function(input)
        if not input or input:trim() == "" then
            Settings.OpenToCategory(category)
        else
            LibStub("AceConfigCmd-3.0").HandleCommand(self, "lui", "LavUI", input)
        end
    end)
end

function LUI:OnEnable()
    self:ApplyScaling()
    self:ApplyACDMTweaks()
    self:AddElvUITags()
end

function LUI:OnDisable()
    self:UnhookAll()
end
