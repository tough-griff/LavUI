---@class LavUI
local LUI = select(2, ...)
setglobal("LUI", LUI)

function LUI:InCombat()
    return InCombatLockdown() or UnitAffectingCombat('player') or UnitAffectingCombat('pet')
end

---@param seconds number
---@param callback TimerCallback
function LUI:Delay(seconds, callback)
    return C_Timer.After(seconds, callback)
end

function LUI:ToggleBars()
    if not ElvUI then return end
    local E = unpack(ElvUI)

    for _, n in pairs({ 1, 3, 4, 5, 6, 13, 14, 15 }) do
        local bar = "bar" .. n
        if E.db.actionbar[bar] then
            E.db.actionbar[bar].mouseover = not E.db.actionbar[bar].mouseover
            E.ActionBars:PositionAndSizeBar(bar)
        end
    end
end

---@param hide? boolean
function LUI:TogglePanel(hide)
    ---@class Frame
    local Panel = RightChatPanel
    if not Details then return end

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

function LUI:ApplyDetailsTweaks()
    if not Details then return end

    -- We don't do the normal SetValue stuff for Details, because if you modify *some* profile values (like tooltip)
    -- without using the global "Details" table, the settings are not persisted.
    for _, profile in ipairs(Details:GetProfileList()) do
        if profile == "atrocityUI" then
            local dtp = Details:GetProfile(profile)

            -- Apply the profile first, so that references to Details below will resolve the correct profile.
            Details:ApplyProfile(profile)

            Details.tooltip.fontsize = 14
            Details.tooltip.fontsize_title = 14
            dtp.font_sizes = { menus = 14 }

            for id, instance in Details:ListInstances() do
                instance:SetBarTextSettings(14)
                instance:AttributeMenu(nil, nil, nil, nil, 14)

                local position = instance:CreatePositionTable()

                position.w = 255

                -- Main damage window
                if id == 1 then
                    position.x = -261
                    position.h = 242
                end

                -- Healing window
                if id == 2 then
                    position.y = 125
                end

                -- Deaths window
                if id == 3 then
                    position.h = 99
                end

                -- DevTool:AddData(position, "Details Instance " .. id .. " Position")
                instance:RestorePositionFromPositionTable(position)
            end

            -- Re-position tooltip for ultra-wide
            Details.tooltip.anchored_to = 2
            Details.tooltip.anchor_point = "bottomright"
            Details.tooltip.anchor_relative = "bottomright"
            Details.tooltip.anchor_offset = { 0, -6 }

            Details.tooltip.anchor_screen_pos = { 1144, -710 }

            Details:SaveProfile(profile)
        end
    end
end
