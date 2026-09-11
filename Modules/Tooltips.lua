---@class LUI
local LUI = select(2, ...)
---@class Tooltips: AceModule, AceEvent-3.0
local Tooltips = LUI:NewModule("Tooltips", "AceEvent-3.0")

local registered = false

function Tooltips:OnInitialize()
    local AES = LibStub("AceAddon-3.0"):GetAddon("atrocityEssentials", true)
    self.TT = AES and AES:GetModule("Tooltips", true)

    if not self.TT then
        LUI:Debug("atrocityEssentials Tooltips module not found, disabling LavUI extensions.")
        self:SetEnabledState(false)
        return
    end

    self:SetEnabledState(LUI.db.global.tooltips)
end

function Tooltips:OnEnable()
    if not LUI.db.global.tooltips then return end

    -- Post-calls can't be removed, so register once and gate the body on the
    -- module's enabled state instead.
    if not registered and self.TT and TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, function(tt, data)
            if self.TT:IsEnabled() then self.TT:OnTooltipSetItem(tt, data) end
        end)

        registered = true
    end
end
