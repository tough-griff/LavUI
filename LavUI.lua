local addon = select(2, ...)

---@class LUI: AceAddon
local LUI = LibStub("AceAddon-3.0"):NewAddon(addon, "LavUI")
_G.LUI = LUI

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

--- === Details Automations === ---

---@param id number
---@param sessionType number 0 = overall, 1 = current, 2 = expired
---@param attributeId number
---@param subAttributeId number
---@param titleOverride? string
local function SetupDetailsInstance(id, sessionType, attributeId, subAttributeId, titleOverride)
    local instance = Details:GetInstance(id)
    if not instance then return end

    instance:SetSegmentType(sessionType, true)
    instance:SetDisplay(nil, attributeId, subAttributeId)

    if titleOverride and instance.menu_attribute_string then
        instance.menu_attribute_string:SetText(titleOverride)
    end
end

---@param zoneType? string
function LUI:SetDetailsSegments(zoneType)
    if not zoneType then zoneType = Details.zone_type or "none" end

    if zoneType == "party" then
        SetupDetailsInstance(1, 1, DETAILS_ATTRIBUTE_DAMAGE, DETAILS_SUBATTRIBUTE_DAMAGEDONE)
        SetupDetailsInstance(2, 0, DETAILS_ATTRIBUTE_DAMAGE, DETAILS_SUBATTRIBUTE_DAMAGEDONE, "Damage Done Overall")
        SetupDetailsInstance(3, 1, DETAILS_ATTRIBUTE_HEAL, DETAILS_SUBATTRIBUTE_HEALDONE)
    elseif zoneType == "raid" then
        SetupDetailsInstance(1, 1, DETAILS_ATTRIBUTE_DAMAGE, DETAILS_SUBATTRIBUTE_DAMAGEDONE)
        SetupDetailsInstance(2, 1, DETAILS_ATTRIBUTE_HEAL, DETAILS_SUBATTRIBUTE_HEALDONE)
        SetupDetailsInstance(3, 1, DETAILS_ATTRIBUTE_MISC, DETAILS_SUBATTRIBUTE_DEATH)
    else
        SetupDetailsInstance(1, 1, DETAILS_ATTRIBUTE_DAMAGE, DETAILS_SUBATTRIBUTE_DAMAGEDONE)
        SetupDetailsInstance(2, 1, DETAILS_ATTRIBUTE_HEAL, DETAILS_SUBATTRIBUTE_HEALDONE)
        SetupDetailsInstance(3, 1, DETAILS_ATTRIBUTE_MISC, DETAILS_SUBATTRIBUTE_DEATH)
    end
end
