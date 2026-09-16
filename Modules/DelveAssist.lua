---@class LUI
local LUI = select(2, ...)
---@class DelveAssist: AceModule, AceEvent-3.0
local DA = LUI:NewModule("DelveAssist", "AceEvent-3.0")

local MACRO_TEXT = "/cleartarget\n/tar dundun\n/tm 1\n/ping [@target] assist"
local ICON = 647701 -- inv_pet_mouse
local BUTTON_SIZE = 36

---@return boolean
local function IsInDelve()
    -- Every lair is a delve, but not every delve is a lair -- match
    -- Blizzard's own InstanceDifficultyMixin:IsInDelve check.
    return C_DelvesUI.HasActiveDelve() and not C_DelvesUI.IsInLair()
end

function DA:ApplyPosition()
    if not self.button then return end
    local cfg = LUI.db.global.delveButton
    self.button:ClearAllPoints()
    self.button:SetPoint(cfg.point, UIParent, cfg.point, cfg.x, cfg.y)
end

function DA:BuildButton()
    if self.button then return true end
    -- Secure attributes can't be set in combat.
    if InCombatLockdown() then return false end

    local btn = CreateFrame("Button", "LUIDelveAssistButton", UIParent, "SecureActionButtonTemplate")
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    -- Both up and down, or the secure click does nothing when the player has
    -- "cast on key down" (ActionButtonUseKeyDown) enabled -- Blizzard's own
    -- action buttons register both for the same reason.
    btn:RegisterForClicks("AnyUp", "AnyDown")
    btn:SetAttribute("type", "macro")
    btn:SetAttribute("macrotext", MACRO_TEXT)

    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetAllPoints()
    btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.icon:SetTexture(ICON)
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

    btn:SetMovable(true)
    btn:EnableMouse(true)
    btn:RegisterForDrag("LeftButton")
    btn:SetClampedToScreen(true)
    btn:SetScript("OnDragStart", function(b)
        if InCombatLockdown() then return end
        b:StartMoving()
    end)
    btn:SetScript("OnDragStop", function(b)
        b:StopMovingOrSizing()
        local point, _, _, x, y = b:GetPoint()
        local cfg = LUI.db.global.delveButton
        cfg.point, cfg.x, cfg.y = point, x, y
    end)

    self.button = btn
    self:ApplyPosition()
    return true
end

function DA:Update()
    local show = LUI.db.global.delveButton.enabled and IsInDelve()
    if not show then
        if self.button then self.button:Hide() end
        return
    end
    if not self:BuildButton() then return end
    self:ApplyPosition()
    self.button:Show()
end

function DA:OnInitialize()
    self:SetEnabledState(LUI.db.global.delveButton.enabled)
end

function DA:OnEnable()
    if not LUI.db.global.delveButton.enabled then return end

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update")
    self:RegisterEvent("UPDATE_INSTANCE_INFO", "Update")
    -- The event Blizzard's own Delve UI (objective tracker, difficulty
    -- picker) refreshes on -- UPDATE_INSTANCE_INFO/PLAYER_ENTERING_WORLD can
    -- fire before C_DelvesUI's data is actually populated on zone-in.
    self:RegisterEvent("ACTIVE_DELVE_DATA_UPDATE", "Update")
    -- The secure button can't be built in combat; retry when it ends.
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "Update")
    self:Update()
end

function DA:OnDisable()
    self:UnregisterAllEvents()
    if self.button then self.button:Hide() end
end
