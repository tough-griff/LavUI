---@class LUI
local LUI = select(2, ...)
---@class Tooltips: AceModule, AceEvent-3.0
local Tooltips = LUI:NewModule("Tooltips", "AceEvent-3.0")

local registered = false

function Tooltips:OnInitialize()
    local AES = LibStub("AceAddon-3.0"):GetAddon("atrocityEssentials", true)
    self.TT = AES and AES:GetModule("Tooltips", true)
    self.EMP = AES and AES:GetModule("ExtendMerchantPages", true)

    if not (self.TT or self.EMP) then
        LUI:Debug("atrocityEssentials Tooltips/ExtendMerchantPages modules not found, disabling LavUI extensions.")
        self:SetEnabledState(false)
        return
    end

    self:SetEnabledState(LUI.db.global.tooltips)
end

local merchantHooked = false

-- AES's ExtendMerchantPages draws its own vendor rows and appends a "Cost:" block
-- to GameTooltip on hover (its file-local AddCostLines). That local can't be hooked,
-- so we post-hook each AE_MerchantRow's OnEnter -- which runs AFTER AES has finished
-- building the tooltip -- and rewrite the cost lines in place: show the owned amount
-- against the required cost ("owned / required") and tint each green/red by
-- affordability. The cost components are the
-- final NumLines() lines of the tooltip, in GetMerchantItemCostItem order.
local function AnnotateCostLines(row)
    if not LUI.db.global.tooltips then return end
    local EMP = Tooltips.EMP
    if not (EMP and EMP:IsEnabled()) then return end

    local index = row.itemIndex
    if not index then return end

    local tt = _G.GameTooltip
    if not tt or tt:IsForbidden() or tt:GetOwner() ~= row then return end

    -- Mirror AES's own guard. A merchant cost can be SECRET on Midnight; if AES bailed
    -- on that it drew no cost block, and rewriting the last lines would then clobber
    -- unrelated item lines. costCount is compared, so it has to be a safe value.
    local info = _G.C_MerchantFrame and _G.C_MerchantFrame.GetItemInfo(index)
    local costCount = info and info.hasExtendedCost and _G.GetMerchantItemCostInfo
        and _G.GetMerchantItemCostInfo(index) or 0
    local ok, positive = pcall(function() return costCount > 0 end)
    if not ok or not positive or not _G.GetMerchantItemCostItem then return end

    -- Same enumeration AES uses (only tex-truthy entries yield a line), so #comps
    -- equals the number of cost lines it appended.
    local comps = {}
    for c = 1, (_G.MAX_ITEM_COST or 3) do
        local tex, value, link, currencyName = _G.GetMerchantItemCostItem(index, c)
        if tex then comps[#comps + 1] = { value = value, link = link, currency = currencyName } end
    end
    if #comps == 0 then return end

    local base = tt:NumLines() - #comps
    if base < 0 then return end

    for k, comp in ipairs(comps) do
        local left = _G["GameTooltipTextLeft" .. (base + k)]
        local right = _G["GameTooltipTextRight" .. (base + k)]
        if left and comp.link then
            -- The owned lookup and the affordability compare can each touch a secret
            -- value; one pcall leaves AES's plain line untouched whenever that happens.
            pcall(function()
                local owned
                if comp.currency then
                    local ci = _G.C_CurrencyInfo and _G.C_CurrencyInfo.GetCurrencyInfoFromLink(comp.link)
                    owned = ci and ci.quantity
                else
                    owned = _G.C_Item.GetItemCount(comp.link, false, false, true)
                end
                if not owned then return end

                local afford = owned >= comp.value
                if right then
                    right:SetText(("%s / %s"):format(BreakUpLargeNumbers(owned), BreakUpLargeNumbers(comp.value)))
                end
                local r, g, b = 1, 0.3, 0.3
                if afford then r, g, b = 0.2, 1, 0.2 end
                left:SetTextColor(r, g, b)
                if right then right:SetTextColor(r, g, b) end
            end)
        end
    end

    tt:Show()
end

function Tooltips:OnEnable()
    if not LUI.db.global.tooltips then return end

    -- Post-calls can't be removed, so register once and gate the body on the
    -- module's enabled state instead.
    if not registered and self.TT and TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, function(tt, data)
            LUI:Debug(tt, "TooltipDataType.UnitAura")
            LUI:Debug(data, "TooltipDataType.UnitAura")
            if self.TT:IsEnabled() then self.TT:OnTooltipSetSpell(tt, data) end
        end)

        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, function(tt, data)
            if self.TT:IsEnabled() then self.TT:OnTooltipSetItem(tt, data) end
        end)

        registered = true
    end

    -- Post-hook each AES merchant row's OnEnter to annotate its cost block. A secure
    -- HookScript can't be removed either, so hook each row once (both those that exist
    -- now and any AcquireButton makes later) and let AnnotateCostLines gate itself.
    if not merchantHooked and self.EMP then
        local function HookRow(i)
            local row = _G["AE_MerchantRow" .. i]
            if row and not row.__lavCostHook then
                row.__lavCostHook = true
                row:HookScript("OnEnter", AnnotateCostLines)
            end
        end
        hooksecurefunc(self.EMP, "AcquireButton", function(_, i) HookRow(i) end)
        for i = 1, (self.EMP._pageSize or 30) do HookRow(i) end
        merchantHooked = true
    end
end
