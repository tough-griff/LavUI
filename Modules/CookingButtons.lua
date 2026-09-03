---@class LUI
local LUI = select(2, ...)
---@class CookingButtons: AceModule, AceEvent-3.0
local CB = LUI:NewModule("CookingButtons", "AceEvent-3.0")

-- Chef's Hat is a toy (item 134020), not an equippable item -- it was converted
-- in 7.0.3. Both buttons are therefore "toy" secure actions.
local CHEFS_HAT = 134020
local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_Food_15"
local BUTTON_SIZE, GAP = 36, 4

-- Registered and unregistered as one set so the two call sites can't drift.
local PROFESSION_EVENTS = {
    "ProfessionsFrame.Show",
    "ProfessionsFrame.Hide",
    "ProfessionsFrame.TabSet",
    "Professions.ProfessionSelected",
}

---@return boolean
local function IsCookingOpen()
    if not ProfessionsFrame or not ProfessionsFrame:IsShown() then return false end
    if not ProfessionsFrame.CraftingPage or not ProfessionsFrame.CraftingPage:IsShown() then return false end
    local info = C_TradeSkillUI.GetChildProfessionInfo()
    return info and info.profession == Enum.Profession.Cooking
end

local function SetItemCooldown(cd, itemID)
    local start, duration, enable = C_Container.GetItemCooldown(itemID)
    if start then CooldownFrame_Set(cd, start, duration, enable) end
end

-- Re-run the hovered button's tooltip a few times a second so its "Cooldown
-- remaining" line keeps counting down instead of freezing, the way Blizzard's
-- own action buttons do.
local function OnButtonUpdate(btn, elapsed)
    btn.ttElapsed = (btn.ttElapsed or 0) + elapsed
    if btn.ttElapsed < 0.2 then return end
    btn.ttElapsed = 0
    if GameTooltip:IsOwned(btn) then btn:ShowTip() end
end

local function OnButtonEnter(btn)
    btn:ShowTip()
    btn:SetScript("OnUpdate", OnButtonUpdate)
end

local function OnButtonLeave(btn)
    btn:SetScript("OnUpdate", nil)
    GameTooltip_Hide()
end

---@param parent Frame
---@param icon string|number
---@param showTip fun(btn: Button)
---@return Button
local function CreateActionButton(parent, name, icon, showTip)
    local btn = CreateFrame("Button", "LUICooking" .. name, parent, "SecureActionButtonTemplate")
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    -- Both up and down, or the secure click does nothing when the player has
    -- "cast on key down" (ActionButtonUseKeyDown) enabled -- Blizzard's own
    -- action buttons register both for the same reason.
    btn:RegisterForClicks("AnyUp", "AnyDown")
    btn:SetAttribute("type", "toy")

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", -1, 1)
    bg:SetPoint("BOTTOMRIGHT", 1, -1)
    bg:SetColorTexture(0, 0, 0, 1)

    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetAllPoints()
    btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.icon:SetTexture(icon)

    btn.cd = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
    btn.cd:SetAllPoints()

    btn.ShowTip = showTip
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    btn:SetScript("OnEnter", OnButtonEnter)
    btn:SetScript("OnLeave", OnButtonLeave)
    return btn
end

--- Accepts a bare toy/item ID or a pasted item link.
---@param input string|number|nil
---@return number?
function CB:ResolveToyID(input)
    if not input then return nil end
    return tonumber(input) or tonumber(tostring(input):match("item:(%d+)"))
end

---@return number?
function CB:GetToyID()
    return self:ResolveToyID(LUI.db.global.cookingButtons.toyID)
end

function CB:BuildHolder()
    if self.holder then return true end
    -- Secure attributes can't be set in combat.
    if InCombatLockdown() then return false end

    local holder = CreateFrame("Frame", "LUICookingButtons", ProfessionsFrame)
    holder:SetSize(BUTTON_SIZE * 2 + GAP, BUTTON_SIZE)
    holder:SetPoint("BOTTOMRIGHT", ProfessionsFrame, "TOPRIGHT", -1, 2)

    self.hat = CreateActionButton(holder, "ChefsHat", C_Item.GetItemIconByID(CHEFS_HAT) or FALLBACK_ICON, function(b)
        GameTooltip:SetOwner(b, "ANCHOR_BOTTOMLEFT")
        GameTooltip:SetToyByItemID(CHEFS_HAT)
        if not PlayerHasToy(CHEFS_HAT) then
            GameTooltip:AddLine("Not in your Toy Box.", 1, 0.3, 0.3)
        end
        GameTooltip:Show()
    end)
    self.hat:SetAttribute("toy", CHEFS_HAT)
    self.hat:SetPoint("RIGHT", holder, "RIGHT", 0, 0)

    self.toy = CreateActionButton(holder, "Toy", FALLBACK_ICON, function(b)
        if not self.toyID then return end
        GameTooltip:SetOwner(b, "ANCHOR_BOTTOMLEFT")
        GameTooltip:SetToyByItemID(self.toyID)
        GameTooltip:Show()
    end)
    self.toy:SetPoint("RIGHT", self.hat, "LEFT", -GAP, 0)

    self.holder = holder
    self:Refresh()
    return true
end

--- Point the toy button at the configured toy and sync icons / visibility.
function CB:Refresh()
    if not self.holder or InCombatLockdown() then return end

    self.hat.icon:SetDesaturated(not PlayerHasToy(CHEFS_HAT))

    local id = self:GetToyID()
    self.toyID = id and PlayerHasToy(id) and id or nil

    if self.toyID then
        self.toy:SetAttribute("toy", self.toyID)
        self.toy.icon:SetTexture(select(3, C_ToyBox.GetToyInfo(self.toyID)) or FALLBACK_ICON)
        self.toy:Show()
        self.holder:SetWidth(BUTTON_SIZE * 2 + GAP)
    else
        self.toy:SetAttribute("toy", nil)
        self.toy:Hide()
        self.holder:SetWidth(BUTTON_SIZE)
    end

    self:UpdateCooldowns()
end

function CB:UpdateCooldowns()
    if not (self.holder and self.holder:IsShown()) then return end
    SetItemCooldown(self.hat.cd, CHEFS_HAT)
    if self.toyID then SetItemCooldown(self.toy.cd, self.toyID) end
end

function CB:Update()
    local show = LUI.db.global.cookingButtons.enabled and IsCookingOpen()
    if not show then
        if self.holder then self.holder:Hide() end
        return
    end
    if not self:BuildHolder() then return end
    self.holder:Show()
    self:Refresh()
end

function CB:HookProfessions()
    if self.hooked then return end
    self.hooked = true
    local onEvent = function() self:Update() end
    for _, event in ipairs(PROFESSION_EVENTS) do
        EventRegistry:RegisterCallback(event, onEvent, self)
    end
    self:Update()
end

function CB:ADDON_LOADED(_, name)
    if name == "Blizzard_Professions" then
        self:UnregisterEvent("ADDON_LOADED")
        self:HookProfessions()
    end
end

function CB:OnInitialize()
    self:SetEnabledState(LUI.db.global.cookingButtons.enabled)
end

function CB:OnEnable()
    if not LUI.db.global.cookingButtons.enabled then return end

    if C_AddOns.IsAddOnLoaded("Blizzard_Professions") then
        self:HookProfessions()
    else
        self:RegisterEvent("ADDON_LOADED")
    end

    self:RegisterEvent("TOYS_UPDATED", "Refresh")
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "UpdateCooldowns")
    self:RegisterEvent("BAG_UPDATE_COOLDOWN", "UpdateCooldowns")
    -- The secure holder can't be built in combat; retry when it ends.
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "Update")
end

function CB:OnDisable()
    self:UnregisterAllEvents()
    for _, event in ipairs(PROFESSION_EVENTS) do
        EventRegistry:UnregisterCallback(event, self)
    end
    self.hooked = nil
    if self.holder then self.holder:Hide() end
end
