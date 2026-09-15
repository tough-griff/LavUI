---@class LUI
local LUI = select(2, ...)
---@class Merchant: AceModule, AceHook-3.0
local Merchant = LUI:NewModule("Merchant", "AceHook-3.0")

function Merchant:OnInitialize()
    local AES = LibStub("AceAddon-3.0"):GetAddon("atrocityEssentials", true)
    self.EMP = AES and AES:GetModule("ExtendMerchantPages", true)

    if not self.EMP then
        LUI:Debug("atrocityEssentials ExtendMerchantPages module not found, disabling LavUI Merchant extensions.")
        self:SetEnabledState(false)
        return
    end

    self:SetEnabledState(LUI.db.global.merchant)
end

-- AES's ExtendMerchantPages draws its own vendor rows and appends a "Cost:" block
-- to GameTooltip on hover (its file-local AddCostLines). That local can't be hooked,
-- so we post-hook each AE_MerchantRow's OnEnter -- which runs AFTER AES has finished
-- building the tooltip -- and rewrite the cost lines in place: show the owned amount
-- against the required cost ("owned / required") and tint each green/red by
-- affordability. The cost components are the
-- final NumLines() lines of the tooltip, in GetMerchantItemCostItem order.
local function AnnotateCostLines(row)
    if not LUI.db.global.merchant then return end
    local EMP = Merchant.EMP
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

-- "Already known" the way WindTools' AlreadyKnown does it: ask the collection
-- journals directly, keyed off the item link, rather than scanning tooltip text.
-- A text scan alone misses collected transmog APPEARANCES (their line differs
-- from a recipe's, and on Midnight it can be a secret value the scan must skip),
-- so the mount/toy/pet/appearance journals answer authoritatively; only recipes,
-- which have no collection API, fall back to the tooltip line. Housing decor has
-- its own storage count via the catalog API, checked the same way.
local knownCache = {}
local ITEM_SPELL_KNOWN = _G.ITEM_SPELL_KNOWN
local PET_KNOWN_PATTERN = _G.ITEM_PET_KNOWN and strmatch(_G.ITEM_PET_KNOWN, "[^%(（]+")

local function IsPetCollected(speciesID)
    if not (speciesID and C_PetJournal and C_PetJournal.GetNumCollectedInfo) then return false end
    local numCollected = C_PetJournal.GetNumCollectedInfo(speciesID)
    return numCollected ~= nil and numCollected > 0
end

local function IsMountCollected(itemID)
    if not (C_MountJournal and C_MountJournal.GetMountFromItem) then return false end
    local mountID = C_MountJournal.GetMountFromItem(itemID)
    return mountID and select(11, C_MountJournal.GetMountInfoByID(mountID)) or false
end

local function IsToyCollected(itemID)
    return C_ToyBox and C_ToyBox.GetToyInfo and C_ToyBox.GetToyInfo(itemID) and PlayerHasToy(itemID) or false
end

local function IsPetItemCollected(itemID)
    if not (C_PetJournal and C_PetJournal.GetPetInfoByItemID) then return false end
    return IsPetCollected(select(13, C_PetJournal.GetPetInfoByItemID(itemID)))
end

-- Vendor-sold housing decor resolves through the catalog, not a collection journal;
-- "owned" means you have any in storage, unredeemed, or already placed.
local function IsDecorAlreadyOwned(itemID)
    if not (C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByItem) then return false end
    local info = C_HousingCatalog.GetCatalogEntryInfoByItem(itemID)
    return info and (info.totalNumStored + info.remainingRedeemable + info.totalNumPlaced) > 0
end

-- Cosmetic-only on purpose: Blizzard shows "Already Known" for a collected
-- appearance ITEM, not for ordinary stat gear that merely shares a known look,
-- so gating on IsCosmeticItem keeps this from greening every vendor armour piece.
local function IsTransmogCollected(link)
    if not (C_TransmogCollection and C_TransmogCollection.PlayerHasTransmogByItemInfo) then return false end
    if not (C_Item and C_Item.IsCosmeticItem and C_Item.IsCosmeticItem(link)) then return false end
    return C_TransmogCollection.PlayerHasTransmogByItemInfo(link) or false
end

-- Returns a tint kind ("known" or "decor") or false, so TintKnownRows can colour
-- decor differently from mounts/pets/toys/transmog/recipes.
local function IsAlreadyKnown(index)
    local link = index and _G.GetMerchantItemLink and _G.GetMerchantItemLink(index)
    if not link then return false end
    if knownCache[link] then return knownCache[link] end

    local ok, kind = pcall(function()
        local linkType, linkID = strmatch(link, "|H(%a+):(%d+)")
        linkID = tonumber(linkID)
        if linkType == "battlepet" then
            return IsPetCollected(linkID) and "known" or false
        elseif linkType == "item" then
            if IsDecorAlreadyOwned(linkID) then
                return "decor"
            end
            if IsMountCollected(linkID) or IsToyCollected(linkID)
                or IsPetItemCollected(linkID) or IsTransmogCollected(link) then
                return "known"
            end
            -- Recipes have no collection API -- read the tooltip line instead,
            -- skipping any secret-valued line (Midnight).
            local data = C_TooltipInfo and C_TooltipInfo.GetHyperlink and C_TooltipInfo.GetHyperlink(link)
            if data and data.lines then
                for _, line in ipairs(data.lines) do
                    local text = line and line.leftText
                    if text ~= nil and not issecretvalue(text) then
                        if (ITEM_SPELL_KNOWN and strfind(text, ITEM_SPELL_KNOWN, 1, true))
                            or (PET_KNOWN_PATTERN and strmatch(text, PET_KNOWN_PATTERN)) then
                            return "known"
                        end
                    end
                end
            end
        end
        return false
    end)

    if ok and kind then
        knownCache[link] = kind
        return kind
    end
    return false
end

-- AES colours each row's plate inside EMP:Refresh; post-hooking that lets us
-- repaint an already-known row AFTER it, so a later Refresh never stomps us.
-- Green (known collectibles) / light blue (owned housing decor) both win over
-- AES's red, and the desaturate/fade it applies to unbuyable rows is undone here
-- so a known row reads as a clean, fully-opaque tint.
local KNOWN_TINT_COLORS = {
    known = { 0.05, 0.38, 0.05 },
    decor = { 0.10, 0.35, 0.60 },
}

local function TintKnownRows(emp)
    if not LUI.db.global.merchant then return end
    if not (emp and emp:IsEnabled()) then return end
    for i = 1, (emp._pageSize or 30) do
        local row = _G["AE_MerchantRow" .. i]
        local kind = row and row:IsShown() and row.itemIndex and IsAlreadyKnown(row.itemIndex)
        local color = kind and KNOWN_TINT_COLORS[kind]
        if color then
            if row.bd and row.bd.SetBackdropColor then
                pcall(row.bd.SetBackdropColor, row.bd, color[1], color[2], color[3], 0.90)
            end
            if row.icon then row.icon:SetDesaturated(false) end
            row:SetAlpha(1)
        end
    end
end

function Merchant:OnEnable()
    if not LUI.db.global.merchant then return end
    if not self.EMP then return end

    -- AceHook so OnDisable's UnhookAll takes them all back off. Cover both the rows
    -- that exist now and any AcquireButton makes later; IsHooked keeps a row from
    -- being hooked twice. AnnotateCostLines runs after AES finishes the row's
    -- tooltip, TintKnownRows after it has coloured the plate.
    local function HookRow(i)
        local row = _G["AE_MerchantRow" .. i]
        if row and not self:IsHooked(row, "OnEnter") then
            self:SecureHookScript(row, "OnEnter", AnnotateCostLines)
        end
    end
    if not self:IsHooked(self.EMP, "AcquireButton") then
        self:SecureHook(self.EMP, "AcquireButton", function(_, i) HookRow(i) end)
    end
    for i = 1, (self.EMP._pageSize or 30) do HookRow(i) end
    if not self:IsHooked(self.EMP, "Refresh") then
        self:SecureHook(self.EMP, "Refresh", TintKnownRows)
    end
end

function Merchant:OnDisable()
    self:UnhookAll()
end
