local _, LUI = ...
local _G = _G

_G.LUI = LUI

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

