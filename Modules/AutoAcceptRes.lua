---@class LUI
local LUI = select(2, ...)
---@class AutoAcceptRes: AceModule, AceEvent-3.0
local AAR = LUI:NewModule("AutoAcceptRes", "AceEvent-3.0")

-- Gated on THREE signals, not one, because the obvious check is wrong: a dead
-- player is not in combat, so InCombatLockdown and UnitAffectingCombat("player")
-- both read "safe" in the middle of a boss fight. Accepting there wastes a
-- battle rez and drops the player straight back into the fight.
--
--   1. our own combat flag, tracked from the combat events rather than asked
--      for at request time (by then the player is dead and clear)
--   2. an active encounter
--   3. the caster still being in combat, which is what catches dungeon trash:
--      no encounter is registered, and the dead player's own flag is clear
--
-- Any one of them means "treat as a combat rez", a SEPARATE opt-in that defaults
-- off. Ported from AtrocityEssentials QoL/Automation.lua (itself from
-- ElvUI_WindTools Modules/Misc/Automation.lua), which gates the same three ways.
--
-- Fails safe: a secret caster name (restricted content -- exactly where battle
-- rezzes happen) cannot be inspected at all. Unknown counts as fighting.
local inCombat = false

local function FightIsLive(casterName)
    if inCombat then return true end
    if IsEncounterInProgress and IsEncounterInProgress() then return true end

    if casterName then
        if issecretvalue(casterName) then return true end
        if UnitExists(casterName) and UnitAffectingCombat(casterName) then return true end
    end

    return false
end

local function Enabled()
    local db = LUI.db.global
    return db.autoAcceptRes or db.autoAcceptCombatRes
end

function AAR:RESURRECT_REQUEST(_, casterName)
    local db = LUI.db.global
    if FightIsLive(casterName) then
        if db.autoAcceptCombatRes then AcceptResurrect() end
    elseif db.autoAcceptRes then
        AcceptResurrect()
    end
end

function AAR:OnInitialize()
    self:SetEnabledState(Enabled())
end

function AAR:OnEnable()
    if not Enabled() then return end

    self:RegisterEvent("RESURRECT_REQUEST")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", function() inCombat = true end)
    self:RegisterEvent("PLAYER_REGEN_ENABLED", function() inCombat = false end)
end

function AAR:OnDisable()
    self:UnregisterAllEvents()
    inCombat = false
end
