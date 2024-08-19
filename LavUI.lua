---@class LavUI
local LUI = select(2, ...)
local _G = _G
local E = unpack(ElvUI)

_G["LUI"] = LUI

function LUI:InCombat()
    return InCombatLockdown() or UnitAffectingCombat('player') or UnitAffectingCombat('pet')
end

function LUI:Delay(seconds, callback)
    return C_Timer.After(seconds, callback)
end

function LUI:ToggleBars()
    for _, n in pairs({ 1, 3, 4, 5, 6, 13, 14, 15 }) do
        E.db.actionbar["bar" .. n].mouseover = not E.db.actionbar["bar" .. n].mouseover
        E.ActionBars:PositionAndSizeBar("bar" .. n)
    end
end

function LUI:TogglePanel(hide)
    local Panel = RightChatPanel
    if hide == true then
        Panel:Hide()
        Details:ReabrirTodasInstancias()
    elseif hide == false then
        Panel:Show()
        Details:ShutDownAllInstances()
    else
        LUI:TogglePanel(Panel:IsShown())
    end
end
