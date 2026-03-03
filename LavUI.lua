local addon = select(2, ...)

--- @class LUI: AceAddon, AceHook-3.0
local LUI = LibStub("AceAddon-3.0"):NewAddon(addon, "LavUI", "AceHook-3.0")
setglobal("LUI", LUI)

-- Utils --
function LUI:Debug(data, dataName)
    if DevTool and data then
        DevTool:AddData(data, format("[LavUI] %s", dataName or "Debug"))
    end
end

function LUI:InCombat()
    return InCombatLockdown() or UnitAffectingCombat('player') or UnitAffectingCombat('pet')
end

function LUI:Split(text, token)
    if token == nil then
        token = "%s"
    end
    local t = {}
    for str in string.gmatch(text, "([^" .. token .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function LUI:StartsWithIgnoreCase(val, starts)
    local lowerVal = string.lower(val)
    local lowerStarts = string.lower(starts)

    return string.sub(lowerVal, 1, #lowerStarts) == lowerStarts
end

function LUI:ContainsIgnoreCase(val, search)
    local lowerVal = string.lower(val)
    local lowerSearch = string.lower(search)

    return string.find(lowerVal, lowerSearch, 1, true) ~= nil
end

-- Bindings and helper functions --
function LUI:ToggleBars()
    if not ElvUI then return end
    local E = unpack(ElvUI)

    for _, n in pairs({ 1, 3, 4, 5, 6, 13, 14, 15 }) do
        local bar = "bar" .. n
        if E.db.actionbar[bar] then
            E.db.actionbar[bar].mouseover = not E.db.actionbar[bar].mouseover
            E.ActionBars:PositionAndSizeBar(bar)
        end
    end
end

---@param hide? boolean
function LUI:TogglePanel(hide)
    if not Details or not RightChatPanel then return end

    ---@class Frame
    local Panel = RightChatPanel
    if hide == true then
        Panel:Hide()
        Details:ReabrirTodasInstancias()
    elseif hide == false then
        Panel:Show()
        Details:ShutDownAllInstances()
    else
        self:TogglePanel(Panel:IsShown())
    end
end

function LUI:AddElvUITags()
    if not ElvUI then return end
    local E = unpack(ElvUI)

    E:AddTag('classcolor:target', 'UNIT_TARGET', function(unit, ...)
        local target = unit .. 'target'
        if UnitExists(target) then
            if UnitIsPlayer(target) or (E.Retail and UnitInPartyIsAI(target)) then
                local _, classToken = UnitClass(target)
                -- Check that this doesn't blow up with secrets
                local cs = E.oUF.colors.class[classToken]
                return cs and Hex(cs) or HEX_FALLBACK
            else
                local cr = E.oUF.colors.reaction[UnitReaction(target, 'player')]
                return cr and Hex(cr) or HEX_FALLBACK
            end
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
    self:LoadProfiles() -- Mostly for debug

    self:ApplyScaling()
    self:AddElvUITags()
end
