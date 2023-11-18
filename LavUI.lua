local _, LUI = ...
local _G = _G

_G.LUI = LUI

function LUI:InCombat()
    return InCombatLockdown() or UnitAffectingCombat('player') or UnitAffectingCombat('pet')
end

function LUI:Delay(seconds, callback)
    return C_Timer.After(seconds, callback)
end

function LUI:TogglePanel(hide)
    local Panel = _G.RightChatPanel
    if (hide) then
        Panel:Hide()
        Details:ReabrirTodasInstancias()
    else
        Panel:Show()
        Details:ShutDownAllInstances()
    end
end
