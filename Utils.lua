local _, addon = ...
local _, Utils = unpack(addon)

function Utils:InCombat()
    return InCombatLockdown() or UnitAffectingCombat('player') or UnitAffectingCombat('pet')
end

function Utils:Delay(seconds, callback)
    return C_Timer.After(seconds, callback)
end

function Utils:TogglePanel(hide)
    local Panel = _G.RightChatPanel
    if (hide) then
        Panel:Hide()
        Details:ReabrirTodasInstancias()
    else
        Panel:Show()
        Details:ShutDownAllInstances()
    end
end
