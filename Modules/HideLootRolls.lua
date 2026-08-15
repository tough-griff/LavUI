---@class LUI
local LUI = select(2, ...)
---@class HideLootRolls: AceModule, AceHook-3.0
local HLR = LUI:NewModule("HideLootRolls", "AceHook-3.0")

function HLR:CancelTimer()
    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end
end

function HLR:OnInitialize()
    self:SetEnabledState(LUI.db.global.hideLootRolls)
end

function HLR:OnEnable()
    if not LUI.db.global.hideLootRolls then return end

    self:SecureHookScript(GroupLootHistoryFrame, "OnShow", function()
        self:CancelTimer()
        self.timer = C_Timer.NewTicker(60, function()
            GroupLootHistoryFrame:Hide()
        end)
    end)

    self:SecureHookScript(GroupLootHistoryFrame, "OnHide", function()
        self:CancelTimer()
    end)
end

function HLR:OnDisable()
    self:CancelTimer()
    self:UnhookAll()
end
