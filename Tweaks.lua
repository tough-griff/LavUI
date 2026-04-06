---@class LUI
local LUI = select(2, ...)
---@class Tweaks: AceModule, AceHook-3.0
local Tweaks = LUI:NewModule("Tweaks", "AceHook-3.0")

Tweaks.profiles = {
    aes = {},
    bigWigs = {},
    br = {},
    elv = { dps = {}, healer = {} },
    elvPrivate = { dps = {}, healer = {} },
    plater = {},
    warpDeplete = {},
}
local profiles = Tweaks.profiles

--- Set the value nested at `path` on all tables in the `destinations` array.
--- The `path` is a string of keys separated by dots, e.g `"actionbar.bar1.buttonSize"`.
---@param destinations table[]
---@param path string
---@param value any
local function SetValue(destinations, path, value)
    -- Do nothing if dest is nil
    if not destinations then return end

    local keys = strsplittable(".", path);

    -- For all entries in the `destinations` table
    for _, tbl in pairs(destinations) do
        -- Traverse the table up to the second-to-last key
        local current = tbl
        for i = 1, #keys - 1 do
            local key = keys[i]
            key = tonumber(key) or key

            -- If the key doesn't exist or isn't a table, create a new table
            if type(current[key]) ~= "table" then
                current[key] = {}
            end
            current = current[key]
        end

        -- Set the value at the final key
        current[keys[#keys]] = value
    end
end

function Tweaks:LoadProfiles()
    -- atrocityEssentials
    if atrocityEssentialsDB then
        for profileName, profile in pairs(atrocityEssentialsDB["profiles"]) do
            if LUI:StartsWithIgnoreCase(profileName, "atrocityui") then
                profiles.aes[profileName] = profile
            end
        end
    end

    -- BigWigs
    if BigWigs3DB then
        for profileName, profile in pairs(BigWigs3DB["namespaces"]["BigWigs_Plugins_Bars"]["profiles"]) do
            if LUI:StartsWithIgnoreCase(profileName, "atrocityui") then
                profiles.bigWigs[profileName] = profile
            end
        end
    end

    -- BuffReminders
    if BuffRemindersDB then
        for profileName, profile in pairs(BuffRemindersDB["profiles"]) do
            if LUI:StartsWithIgnoreCase(profileName, "atrocityui") then
                profiles.br[profileName] = profile
            end
        end
    end

    -- ElvUI Base
    if ElvDB then
        for profileName, profile in pairs(ElvDB["profiles"]) do
            if LUI:StartsWithIgnoreCase(profileName, "atrocityui") then
                if LUI:ContainsIgnoreCase(profileName, "healer") then
                    profiles.elv.healer[profileName] = profile
                else
                    profiles.elv.dps[profileName] = profile
                end
            end
        end
    end

    -- ElvUI Private
    if ElvPrivateDB then
        for profileName, profile in pairs(ElvPrivateDB["profiles"]) do
            if LUI:StartsWithIgnoreCase(profileName, "atrocityui") then
                if LUI:ContainsIgnoreCase(profileName, "healer") then
                    profiles.elvPrivate.healer[profileName] = profile
                else
                    profiles.elvPrivate.dps[profileName] = profile
                end
            end
        end
    end

    -- WarpDeplete
    if WarpDepleteDB then
        for profileName, profile in pairs(WarpDepleteDB["profiles"]) do
            if LUI:StartsWithIgnoreCase(profileName, "atrocityui") then
                profiles.warpDeplete[profileName] = profile
            end
        end
    end

    -- Plater
    if Plater then
        for profileName, profile in pairs(Plater.db["profiles"]) do
            if LUI:StartsWithIgnoreCase(profileName, "atrocityui") then
                profiles.plater[profileName] = profile
            end
        end
    end

    LUI:Debug(profiles, "LoadProfiles")
end

function Tweaks:ApplyAtrocityEssentialsConfig()
    local config = LUI.db.global.atrocityUI

    if config.aes.disableAutomations then
        SetValue(profiles.aes, "Miscellaneous.Automation.AutoAcceptQuests", false)
        SetValue(profiles.aes, "Miscellaneous.Automation.AutoTurnInQuests", false)
        SetValue(profiles.aes, "Miscellaneous.Automation.HideTalkingHead", false)
    end

    if config.aes.disableCopyAnything then
        SetValue(profiles.aes, "Miscellaneous.CopyAnything.Enabled", false)
    end

    if config.aes.enableCombatCross then
        SetValue(profiles.aes, "CombatCross.Enabled", true)
    end

    -- LUI has its own hotkey for hiding its modified action bars using the mouseover state.
    SetValue(profiles.aes, "Miscellaneous.HideBars.Enabled", false)
end

function Tweaks:ApplyBigWigsConfig()
    if not BigWigs3DB then return end

    local config = LUI.db.global.atrocityUI

    if config.fonts.resize then
        SetValue(profiles.bigWigs, "fontSize", config.fonts.size)
        SetValue(profiles.bigWigs, "fontSizeEmph", config.fonts.size)
    end

    if config.bigWigs then
        local yPosition = -3
        local width = 197

        if config.elvUI.minimapDataTexts then
            yPosition = yPosition - 22
        end

        if config.elvUI.minimap then
            width = 263
        end

        SetValue(profiles.bigWigs, "normalPosition", { "TOPRIGHT", "BOTTOMRIGHT", 0, yPosition, "Minimap" })
        SetValue(profiles.bigWigs, "normalWidth", width)
        SetValue(profiles.bigWigs, "visibleBarLimit", 5)
        SetValue(profiles.bigWigs, "visibleBarLimitEmph", 5)
    end
end

function Tweaks:ApplyBuffRemindersConfig()
    if not BuffReminders then return end

    local config = LUI.db.global.atrocityUI

    if config.buffReminders.smart then
        SetValue(profiles.br, "BuffTrackingMode", "smart")
    end
end

local SHARED_BAR_SETTINGS = {
    ["backdrop"] = false,
    ["buttonSpacing"] = 1,
    ["countFont"] = "Expressway",
    ["countFontOutline"] = "OUTLINE",
    ["countFontSize"] = 14,
    ["countTextPosition"] = "BOTTOM",
    ["countTextXOffset"] = 1,
    ["countTextYOffset"] = 2,
    ["hotkeyFont"] = "Expressway",
    ["hotkeyFontOutline"] = "OUTLINE",
    ["hotkeyFontSize"] = 14,
    ["hotkeyTextPosition"] = "TOP",
    ["hotkeyTextXOffset"] = 1,
    ["hotkeyTextYOffset"] = -1,
    ["macroFont"] = "Expressway",
    ["macroFontOutline"] = "OUTLINE",
    ["macroFontSize"] = 14,
    ["macroTextPosition"] = "CENTER",
    ["macroTextXOffset"] = 1,
    ["macroTextYOffset"] = 0,
}

function Tweaks:ApplyDetailsConfig()
    if not Details then return end

    local config = LUI.db.global.atrocityUI

    -- We don't do the normal SetValue stuff for Details, because if you modify *some* profile values (like tooltip)
    -- without using the global "Details" table, the settings are not persisted.
    for _, profile in ipairs(Details:GetProfileList()) do
        if LUI:StartsWithIgnoreCase(profile, "atrocityui") then
            local dtp = Details:GetProfile(profile)

            -- Apply the profile first, so that references to Details below will resolve the correct profile.
            Details:ApplyProfile(profile)

            if LUI.db.global.scaleFactor then
                dtp.options_window = { scale = LUI.db.global.scaleFactor }
            end

            if config.fonts.resize then
                Details.tooltip.fontsize = config.fonts.size
                Details.tooltip.fontsize_title = config.fonts.size
                dtp.font_sizes = { menus = config.fonts.size }
            end

            Details:ReopenAllWindows()
            for id, instance in Details:ListInstances() do
                if config.fonts.resize then
                    instance:SetBarTextSettings(config.fonts.size)
                    instance:AttributeMenu(nil, nil, nil, nil, config.fonts.size)
                end

                if config.elvUI.panels then
                    local position = instance:CreatePositionTable()

                    position.w = config.elvUI.panelWidth / 2 - 2

                    -- Main damage window
                    if id == 1 then
                        position.x = -config.elvUI.panelWidth / 2 - 4
                        position.h = config.elvUI.panelHeight - 26
                    end

                    -- Healing window
                    if id == 2 then
                        position.y = 125
                    end

                    -- Deaths window
                    if id == 3 then
                        position.h = 99
                    end

                    instance:RestorePositionFromPositionTable(position)
                end
            end

            -- Re-position tooltip for ultrawide
            if config.details then
                Details.tooltip.anchored_to = 2
                Details.tooltip.anchor_point = "bottomright"
                Details.tooltip.anchor_relative = "bottomright"
                Details.tooltip.anchor_offset = { 0, -6 }

                if config.elvUI.panels then
                    Details.tooltip.anchor_screen_pos = { 1144, -710 }
                end
            end

            Details:SaveProfile(profile)
        end
    end
end

function ApplySharedBarSettings(profile, bar)
    for setting, value in pairs(SHARED_BAR_SETTINGS) do
        SetValue(profile, format("actionbar.%s.%s", bar, setting), value)
    end
end

local ACTION_BAR_SETTINGS = {
    ["bar1"] = {
        ["buttonSize"] = 33,
        ["buttons"] = 12,
        ["buttonsPerRow"] = 12,
        ["enabled"] = true,
        ["mouseover"] = true,
        ["point"] = "BOTTOMLEFT",
        ["visibility"] = "[petbattle] hide; show",
    },
    ["bar2"] = {
        ["buttonSize"] = 40,
        ["buttons"] = 6,
        ["buttonsPerRow"] = 6,
        ["enabled"] = true,
        ["mouseover"] = false,
        ["point"] = "TOPLEFT",
        ["visibility"] = "[overridebar][vehicleui][possessbar][bonusbar:5] show; hide",
    },
    ["bar3"] = {
        ["buttonSize"] = 33,
        ["buttons"] = 12,
        ["buttonsPerRow"] = 6,
        ["enabled"] = true,
        ["mouseover"] = true,
        ["point"] = "BOTTOMLEFT",
        ["visibility"] = "[petbattle] hide; show",
    },
    ["bar4"] = {
        ["buttonSize"] = 42,
        ["buttons"] = 12,
        ["buttonsPerRow"] = 1,
        ["enabled"] = true,
        ["mouseover"] = true,
        ["point"] = "BOTTOMLEFT",
        ["visibility"] = "[petbattle] hide; show",
    },
    ["bar5"] = {
        ["buttonSize"] = 33,
        ["buttons"] = 12,
        ["buttonsPerRow"] = 6,
        ["enabled"] = true,
        ["mouseover"] = true,
        ["point"] = "BOTTOMLEFT",
        ["visibility"] = "[petbattle] hide; show",
    },
    ["bar6"] = {
        ["buttonSize"] = 33,
        ["buttons"] = 12,
        ["buttonsPerRow"] = 12,
        ["enabled"] = true,
        ["mouseover"] = true,
        ["point"] = "BOTTOMLEFT",
        ["visibility"] = "[petbattle] hide; show",
    },
    ["bar13"] = {
        ["buttonSize"] = 42,
        ["buttonsPerRow"] = 2,
        ["buttons"] = 10,
        ["enabled"] = true,
        ["mouseover"] = true,
        ["point"] = "BOTTOMLEFT",
        ["visibility"] = "[petbattle] hide; show",
    },
    ["barPet"] = {
        ["buttonSize"] = 42,
        ["buttonsPerRow"] = 2,
        ["buttons"] = 10,
        ["enabled"] = true,
        ["mouseover"] = true,
        ["point"] = "TOPLEFT",
        ["visibility"] = "[petbattle] hide; [novehicleui,pet,nooverridebar,nopossessbar] show; hide",
    },
}

function ApplyElvUIBarConfig(profile)
    local config = LUI.db.global.atrocityUI

    -- "global" actionbar settings
    SetValue(profile, "actionbar.font", "Expressway")
    SetValue(profile, "actionbar.fontOutline", "OUTLINE")
    SetValue(profile, "actionbar.fontSize", 14)
    SetValue(profile, "actionbar.countTextPosition", "BOTTOMRIGHT")
    SetValue(profile, "actionbar.countTextXOffset", 1)
    SetValue(profile, "actionbar.countTextYOffset", 2)
    SetValue(profile, "actionbar.hotkeyTextPosition", "TOPRIGHT")
    SetValue(profile, "actionbar.hotkeyTextXOffset", 1)
    SetValue(profile, "actionbar.hotkeyTextYOffset", -2)
    SetValue(profile, "actionbar.macroTextPosition", "BOTTOM")
    SetValue(profile, "actionbar.macroTextXOffset", 0)
    SetValue(profile, "actionbar.macroTextYOffset", 0)

    -- specific bar settings from table above
    for bar, settings in pairs(ACTION_BAR_SETTINGS) do
        ApplySharedBarSettings(profile, bar)
        for setting, value in pairs(settings) do
            SetValue(profile, format("actionbar.%s.%s", bar, setting), value)
        end
    end

    -- Movers
    SetValue(profile, "movers.ElvAB_1", "BOTTOM,ElvUIParent,BOTTOM,0.1,3")
    SetValue(profile, "movers.ElvAB_2", "BOTTOM,ElvUIParent,BOTTOM,0.1,245")
    SetValue(profile, "movers.ElvAB_3", "BOTTOM,ElvUIParent,BOTTOM,-305.1,3")
    SetValue(profile, "movers.ElvAB_4", "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-3,462")
    SetValue(profile, "movers.ElvAB_5", "BOTTOM,ElvUIParent,BOTTOM,306.1,3")
    SetValue(profile, "movers.ElvAB_6", "BOTTOM,ElvUIParent,BOTTOM,0.1,37")

    local panelOffset = (config.elvUI.panels and config.elvUI.panelWidth or 399) + 4
    SetValue(profile, "movers.ElvAB_13", format("BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,%d,3", panelOffset))
    SetValue(profile, "movers.PetAB", format("BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-%d,3", panelOffset))
end

function Tweaks:ApplyElvUIConfig()
    if not ElvUI then return end
    local E = unpack(ElvUI)
    local config = LUI.db.global.atrocityUI

    local descaledFontSize = math.floor(config.fonts.size - (config.fonts.size * (LUI.db.global.scaleFactor - 1)))
    local diminishedFontSize = math.ceil((config.fonts.size - descaledFontSize) / 2) + config.fonts.size

    if config.fonts.resize then
        -- Fonts
        SetValue(profiles.elvPrivate.dps, "general.nameplateFontSize", config.fonts.size)
        SetValue(profiles.elvPrivate.dps, "general.nameplateLargeFontSize", config.fonts.size)
        SetValue(profiles.elvPrivate.dps, "general.chatBubbleFontSize", descaledFontSize)
        SetValue(profiles.elvPrivate.healer, "general.nameplateFontSize", config.fonts.size)
        SetValue(profiles.elvPrivate.healer, "general.nameplateLargeFontSize", config.fonts.size)
        SetValue(profiles.elvPrivate.healer, "general.chatBubbleFontSize", descaledFontSize)

        local smallFont = {
            enable = true,
            outline = "OUTLINE",
            size = descaledFontSize
        }

        local normalFont = {
            enable = true,
            outline = "OUTLINE",
            size = diminishedFontSize
        }

        SetValue(profiles.elv.dps, "general.fonts.objective", smallFont)
        SetValue(profiles.elv.dps, "general.fonts.questsmall", normalFont)
        SetValue(profiles.elv.dps, "general.fonts.questtext", normalFont)
        SetValue(profiles.elv.dps, "general.fonts.questtitle", normalFont)
        SetValue(profiles.elv.dps, "general.fonts.mailbody", normalFont)
        SetValue(profiles.elv.dps, "general.fonts.errortext", normalFont)
        SetValue(profiles.elv.healer, "general.fonts.objective", smallFont)
        SetValue(profiles.elv.healer, "general.fonts.questsmall", normalFont)
        SetValue(profiles.elv.healer, "general.fonts.questtext", normalFont)
        SetValue(profiles.elv.healer, "general.fonts.questtitle", normalFont)
        SetValue(profiles.elv.healer, "general.fonts.mailbody", normalFont)
        SetValue(profiles.elv.healer, "general.fonts.errortext", normalFont)
    end

    if config.elvUI.databars then
        -- Data Bars
        if config.fonts.resize then
            SetValue(profiles.elv.dps, "databars.experience.fontSize", config.fonts.size)
            SetValue(profiles.elv.healer, "databars.experience.fontSize", config.fonts.size)
        end

        SetValue(profiles.elv.dps, "databars.experience.height", 20)
        SetValue(profiles.elv.healer, "databars.experience.height", 20)

        SetValue(profiles.elv.dps, "databars.experience.showLevel", true)
        SetValue(profiles.elv.healer, "databars.experience.showLevel", true)

        SetValue(profiles.elv.dps, "databars.experience.questCompletedOnly", true)
        SetValue(profiles.elv.healer, "databars.experience.questCompletedOnly", true)
    end

    if config.elvUI.disableBags then
        -- Bags
        SetValue(profiles.elvPrivate.dps, "bags.enable", false)
        SetValue(profiles.elvPrivate.healer, "bags.enable", false)
    end

    if config.fonts.resize then
        -- Alternative Power Bar
        SetValue(profiles.elv.dps, "general.altPowerBar.fontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "general.altPowerBar.fontSize", config.fonts.size)

        -- Blizzard UI Improvements
        SetValue(profiles.elv.dps, "general.lootRoll.nameFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "general.lootRoll.nameFontSize", config.fonts.size)

        SetValue(profiles.elv.dps, "general.itemLevel.itemLevelFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "general.itemLevel.itemLevelFontSize", config.fonts.size)

        SetValue(profiles.elv.dps, "general.queueStatus.fontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "general.queueStatus.fontSize", config.fonts.size)

        -- Extra Action Button
        SetValue(profiles.elv.dps, "actionbar.extraActionButton.hotkeyFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "actionbar.extraActionButton.hotkeyFontSize", config.fonts.size)
    end

    -- Dungeon Queue Icon
    SetValue(profiles.elv.dps, "general.queueStatus.scale", 0.4)
    SetValue(profiles.elv.healer, "general.queueStatus.scale", 0.4)

    if config.fonts.resize then
        -- Auras
        SetValue(profiles.elv.dps, "auras.debuffs.timeFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "auras.debuffs.timeFontSize", config.fonts.size)

        SetValue(profiles.elv.dps, "auras.debuffs.countFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "auras.debuffs.countFontSize", config.fonts.size)

        SetValue(profiles.elv.dps, "auras.buffs.timeFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "auras.buffs.timeFontSize", config.fonts.size)

        SetValue(profiles.elv.dps, "auras.buffs.countFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "auras.buffs.countFontSize", config.fonts.size)

        -- Chat
        SetValue(profiles.elv.dps, "chat.fontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "chat.fontSize", config.fonts.size)

        SetValue(profiles.elv.dps, "chat.tabFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "chat.tabFontSize", config.fonts.size)
    end

    if config.elvUI.panels then
        -- Chat continued
        SetValue(profiles.elv.dps, "chat.panelWidth", config.elvUI.panelWidth)
        SetValue(profiles.elv.healer, "chat.panelWidth", config.elvUI.panelWidth)

        SetValue(profiles.elv.dps, "chat.panelHeight", config.elvUI.panelHeight)
        SetValue(profiles.elv.healer, "chat.panelHeight", config.elvUI.panelHeight)

        if not config.elvUI.actionbars then
            -- this is here because we don't want to use 12 buttons unless
            -- we are resizing the chat panels, too.
            SetValue(profiles.elv.dps, "actionbar.bar3.buttons", 12)
            SetValue(profiles.elv.healer, "actionbar.bar3.buttons", 12)

            SetValue(profiles.elv.dps, "actionbar.bar3.buttonSize", 43)
            SetValue(profiles.elv.healer, "actionbar.bar3.buttonSize", 43)
        end

        SetValue(profiles.elv.dps, "actionbar.barPet.buttonSize", 43)
        SetValue(profiles.elv.healer, "actionbar.barPet.buttonSize", 43)
    end

    if config.elvUI.panelBackdrop then
        SetValue(profiles.elv.dps, "chat.panelBackdrop", "HIDEBOTH")
        SetValue(profiles.elv.dps, "chat.fadeTabsNoBackdrop", true)
        SetValue(profiles.elv.dps, "chat.fadeChatToggles", true)
        SetValue(profiles.elv.healer, "chat.fadeChatToggles", true)
        SetValue(profiles.elv.dps, "chat.fade", true)
        SetValue(profiles.elv.dps, "chat.inactivityTimer", 120)
        SetValue(profiles.elv.healer, "chat.panelBackdrop", "HIDEBOTH")
        SetValue(profiles.elv.healer, "chat.fadeTabsNoBackdrop", true)
        SetValue(profiles.elv.healer, "chat.fadeChatToggles", true)
        SetValue(profiles.elv.healer, "chat.fade", true)
        SetValue(profiles.elv.healer, "chat.inactivityTimer", 120)
    end

    -- DataTexts
    if config.fonts.resize then
        SetValue(profiles.elv.dps, "datatexts.fontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "datatexts.fontSize", config.fonts.size)
    end

    SetValue(profiles.elv.dps, "datatexts.panels.MinimapPanel.enable", config.elvUI.minimapDataTexts)
    SetValue(profiles.elv.dps, "datatexts.panels.MinimapPanel.backdrop", true)
    SetValue(profiles.elv.healer, "datatexts.panels.MinimapPanel.enable", config.elvUI.minimapDataTexts)
    SetValue(profiles.elv.healer, "datatexts.panels.MinimapPanel.backdrop", true)

    -- Maps
    E.global.general.smallerWorldMap = true
    E.global.general.WorldMapCoordinates.enable = true

    if config.fonts.resize then
        SetValue(profiles.elv.dps, "general.minimap.locationFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "general.minimap.locationFontSize", config.fonts.size)

        SetValue(profiles.elv.dps, "general.minimap.timeFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "general.minimap.timeFontSize", config.fonts.size)
    end

    if config.elvUI.minimap then
        -- Minimap
        E.global.datatexts.customPanels.Clock.width = 261
        E.global.datatexts.customPanels.Clock.textJustify = "CENTER"

        SetValue(profiles.elv.dps, "general.minimap.scale", 1.24)
        SetValue(profiles.elv.healer, "general.minimap.scale", 1.24)

        SetValue(profiles.elv.dps, "general.minimap.size", 212)
        SetValue(profiles.elv.healer, "general.minimap.size", 212)
    end

    if config.fonts.resize then
        -- Tooltip
        SetValue(profiles.elv.dps, "tooltip.headerFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "tooltip.headerFontSize", config.fonts.size)

        SetValue(profiles.elv.dps, "tooltip.textFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "tooltip.textFontSize", config.fonts.size)

        SetValue(profiles.elv.dps, "tooltip.smallTextFontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "tooltip.smallTextFontSize", config.fonts.size)
    end

    if config.elvUI.tooltip then
        SetValue(profiles.elv.dps, "tooltip.modifierID", "SHIFT")
        SetValue(profiles.elv.healer, "tooltip.modifierID", "SHIFT")

        SetValue(profiles.elv.dps, "tooltip.itemCount", "NONE")
        SetValue(profiles.elv.healer, "tooltip.itemCount", "NONE")
    end

    if config.fonts.resize then
        -- Unit Frames
        SetValue(profiles.elv.dps, "unitframe.fontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "unitframe.fontSize", config.fonts.size)

        SetValue(profiles.elv.dps, "unitframe.units.party.raidRoleIcons.xOffset", -27)

        SetValue(profiles.elv.dps, "unitframe.units.raid1.buffs.countFontSize", diminishedFontSize)
        SetValue(profiles.elv.healer, "unitframe.units.raid1.buffs.countFontSize", diminishedFontSize)

        SetValue(profiles.elv.dps, "unitframe.units.raid2.buffs.countFontSize", diminishedFontSize)
        SetValue(profiles.elv.healer, "unitframe.units.raid2.buffs.countFontSize", diminishedFontSize)

        SetValue(profiles.elv.dps, "unitframe.units.raid3.buffs.countFontSize", diminishedFontSize)
        SetValue(profiles.elv.healer, "unitframe.units.raid3.buffs.countFontSize", diminishedFontSize)
    end

    if config.elvUI.panels then
        local width = config.elvUI.panelWidth / 5 - 1
        SetValue(profiles.elv.dps, "unitframe.units.raid1.width", width)
        SetValue(profiles.elv.dps, "unitframe.units.raid2.width", width)
        SetValue(profiles.elv.dps, "unitframe.units.raid3.width", width)
    end

    SetValue(profiles.elv.dps, "unitframe.units.raid1.roleIcon.enable", true)
    SetValue(profiles.elv.dps, "unitframe.units.raid1.roleIcon.damager", false)
    SetValue(profiles.elv.healer, "unitframe.units.raid1.roleIcon.enable", true)
    SetValue(profiles.elv.healer, "unitframe.units.raid1.roleIcon.damager", false)

    SetValue(profiles.elv.dps, "unitframe.units.raid2.roleIcon.enable", true)
    SetValue(profiles.elv.dps, "unitframe.units.raid2.roleIcon.damager", false)
    SetValue(profiles.elv.healer, "unitframe.units.raid2.roleIcon.enable", true)
    SetValue(profiles.elv.healer, "unitframe.units.raid2.roleIcon.damager", false)

    SetValue(profiles.elv.dps, "unitframe.units.raid3.roleIcon.enable", true)
    SetValue(profiles.elv.dps, "unitframe.units.raid3.roleIcon.damager", false)
    SetValue(profiles.elv.healer, "unitframe.units.raid3.roleIcon.enable", true)
    SetValue(profiles.elv.healer, "unitframe.units.raid3.roleIcon.damager", false)

    -- Auto repairs
    if not config.elvUI.guildRepairs then
        SetValue(profiles.elv.dps, "general.autoRepair", "PLAYER")
        SetValue(profiles.elv.healer, "general.autoRepair", "PLAYER")
    end

    -- Auto accept invites
    SetValue(profiles.elv.dps, "general.autoAcceptInvite", config.elvUI.autoAcceptInvites)
    SetValue(profiles.elv.healer, "general.autoAcceptInvite", config.elvUI.autoAcceptInvites)

    -- Nicknames
    if config.elvUI.nicknames then
        SetValue(profiles.elv.dps, "unitframe.units.party.name.text_format", "[classcolor][NSNickName] [afk]")
        SetValue(profiles.elv.healer, "unitframe.units.party.name.text_format", "[classcolor][NSNickName] [afk]")

        SetValue(profiles.elv.dps, "unitframe.units.raid1.name.text_format", "[classcolor][NSNickName]")
        SetValue(profiles.elv.dps, "unitframe.units.raid2.name.text_format", "[classcolor][NSNickName]")
        SetValue(profiles.elv.dps, "unitframe.units.raid3.name.text_format", "[classcolor][NSNickName]")
        SetValue(profiles.elv.healer, "unitframe.units.raid1.name.text_format", "[classcolor][NSNickName]")
        SetValue(profiles.elv.healer, "unitframe.units.raid2.name.text_format", "[classcolor][NSNickName]")
        SetValue(profiles.elv.healer, "unitframe.units.raid3.name.text_format", "[classcolor][NSNickName]")
    end

    -- Actionbar Overhaul
    if config.elvUI.actionbars then
        ApplyElvUIBarConfig(profiles.elv.dps)
        ApplyElvUIBarConfig(profiles.elv.healer)
    end

    -- Add the zzz tag
    if config.elvUI.unitFrameRestIcon then
        SetValue(profiles.elv.dps, "unitframe.units.player.RestIcon.enable", true)
        SetValue(profiles.elv.dps, "unitframe.units.player.RestIcon.anchorPoint", "TOPLEFT")
        SetValue(profiles.elv.dps, "unitframe.units.player.RestIcon.size", 22)
        SetValue(profiles.elv.dps, "unitframe.units.player.RestIcon.texture", "Resting0")
        SetValue(profiles.elv.dps, "unitframe.units.player.RestIcon.xOffset", 2)
        SetValue(profiles.elv.dps, "unitframe.units.player.RestIcon.yOffset", -2)
        SetValue(profiles.elv.healer, "unitframe.units.player.RestIcon.enable", true)
        SetValue(profiles.elv.healer, "unitframe.units.player.RestIcon.anchorPoint", "TOPLEFT")
        SetValue(profiles.elv.healer, "unitframe.units.player.RestIcon.size", 22)
        SetValue(profiles.elv.healer, "unitframe.units.player.RestIcon.texture", "Resting0")
        SetValue(profiles.elv.healer, "unitframe.units.player.RestIcon.xOffset", 2)
        SetValue(profiles.elv.healer, "unitframe.units.player.RestIcon.yOffset", -2)
    end

    if config.elvUI.disableSkins then
        -- `enable` is just another field in `skins.blizzard` like the individual skin toggles.
        local ENABLED_SKINS = { "enable", "misc", "objectiveTracker", "tooltip" }

        for skin in pairs(E.private.skins.blizzard) do
            local enable = tContains(ENABLED_SKINS, skin)
            SetValue(profiles.elvPrivate.dps, format("skins.blizzard.%s", skin), enable)
            SetValue(profiles.elvPrivate.healer, format("skins.blizzard.%s", skin), enable)
        end
    end

    -- Movers
    if config.elvUI.minimap then
        SetValue(profiles.elv.dps, "movers.BNETMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-290")
        SetValue(profiles.elv.healer, "movers.BNETMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-290")

        SetValue(profiles.elv.dps, "movers.DTPanelClockMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-250")
        SetValue(profiles.elv.healer, "movers.DTPanelClockMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-250")

        SetValue(profiles.elv.dps, "movers.BuffsMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-269,-3")
        SetValue(profiles.elv.healer, "movers.BuffsMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-269,-3")

        SetValue(profiles.elv.dps, "movers.DebuffsMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-269,-230")
        SetValue(profiles.elv.healer, "movers.DebuffsMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-269,-230")

        SetValue(profiles.elv.dps, "movers.QueueStatusMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-8,-210")
        SetValue(profiles.elv.healer, "movers.QueueStatusMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-8,-210")
    end

    SetValue(profiles.elv.dps, "movers.WTMinimapButtonBarAnchor", "BOTTOMLEFT,Minimap,BOTTOMLEFT,3,3")
    SetValue(profiles.elv.healer, "movers.WTMinimapButtonBarAnchor", "BOTTOMLEFT,Minimap,BOTTOMLEFT,3,3")

    if config.elvUI.panels then
        local PetAB = format("BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,%d,3", -config.elvUI.panelWidth - 4)
        SetValue(profiles.elv.dps, "movers.PetAB", PetAB)
        SetValue(profiles.elv.healer, "movers.PetAB", PetAB)

        if not config.elvUI.actionbars then
            local AB3 = format("BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,%d,3", config.elvUI.panelWidth + 4)
            SetValue(profiles.elv.dps, "movers.ElvAB_3", AB3)
            SetValue(profiles.elv.healer, "movers.ElvAB_3", AB3)
        end

        local VehicleLeaveButton = format("BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,%d,%d",
            -config.elvUI.panelWidth + 27,
            config.elvUI.panelHeight + 7)
        SetValue(profiles.elv.dps, "movers.VehicleLeaveButton", VehicleLeaveButton)
        SetValue(profiles.elv.healer, "movers.VehicleLeaveButton", VehicleLeaveButton)

        local TooltipMover = format("BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-2,%d", config.elvUI.panelHeight - 34)
        SetValue(profiles.elv.dps, "movers.TooltipMover", TooltipMover)
        SetValue(profiles.elv.healer, "movers.TooltipMover", TooltipMover)

        local DTPanelBugsMover = format("BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,%d,%d",
            config.elvUI.panelWidth - 21,
            config.elvUI.panelHeight - 19)
        SetValue(profiles.elv.dps, "movers.DTPanelBugsMover", DTPanelBugsMover)
        SetValue(profiles.elv.healer, "movers.DTPanelBugsMover", DTPanelBugsMover)
    end

    if config.elvUI.lowerLeftRaidFrames then
        local height = (config.elvUI.panels and config.elvUI.panelHeight or 214) + 23
        local RaidMover = format("BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,3,%d", height)
        SetValue(profiles.elv.dps, "movers.ElvUF_Raid1Mover", RaidMover)
        SetValue(profiles.elv.dps, "movers.ElvUF_Raid2Mover", RaidMover)
        SetValue(profiles.elv.dps, "movers.ElvUF_Raid3Mover", RaidMover)
    end

    SetValue(profiles.elv.dps, "movers.LossControlMover", "TOP,ElvUIParent,TOP,0,-500")
    SetValue(profiles.elv.healer, "movers.LossControlMover", "TOP,ElvUIParent,TOP,0,-500")

    if config.elvUI.unitFrames then
        SetValue(profiles.elv.dps, "movers.BossHeaderMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-706,-445")
        SetValue(profiles.elv.healer, "movers.BossHeaderMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-706,-445")

        SetValue(profiles.elv.dps, "movers.ArenaHeaderMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-676,-398")
        SetValue(profiles.elv.healer, "movers.ArenaHeaderMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-676,-398")

        SetValue(profiles.elv.dps, "movers.LootFrameMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-1060,-585")
        SetValue(profiles.elv.healer, "movers.LootFrameMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-1060,-585")

        SetValue(profiles.elv.dps, "movers.ElvUF_PartyMover", "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,965,535")

        -- Anchor focus frame to target frame
        SetValue(profiles.elv.dps, "ElvUI_Anchor.focusEnabled", true)
        SetValue(profiles.elv.dps, "ElvUI_Anchor.focusParent", "ElvUF_Target")
        SetValue(profiles.elv.dps, "ElvUI_Anchor.focusPoint", "LEFT")
        SetValue(profiles.elv.dps, "ElvUI_Anchor.focusRelative", "RIGHT")
        SetValue(profiles.elv.dps, "ElvUI_Anchor.focusX", 65)
        SetValue(profiles.elv.dps, "ElvUI_Anchor.focusY", 37)
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusEnabled", true)
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusParent", "ElvUF_Target")
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusPoint", "LEFT")
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusRelative", "RIGHT")
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusX", 65)
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusY", 37)
    end
end

function Tweaks:ApplyPlaterConfig()
    if not Plater then return end

    local config = LUI.db.global.atrocityUI

    if config.plater.fonts.resize then
        SetValue(profiles.plater, "plate_config.enemynpc.actorname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemynpc.big_actorname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemynpc.big_actortitle_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemynpc.level_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemynpc.percent_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemynpc.spellname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemynpc.spellpercent_text_size", config.plater.fonts.size)

        SetValue(profiles.plater, "plate_config.enemyplayer.actorname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemyplayer.big_actorname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemyplayer.big_actortitle_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemyplayer.level_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemyplayer.percent_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemyplayer.spellname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.enemyplayer.spellpercent_text_size", config.plater.fonts.size)

        SetValue(profiles.plater, "plate_config.friendlynpc.actorname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlynpc.big_actorname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlynpc.big_actortitle_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlynpc.level_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlynpc.percent_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlynpc.spellname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlynpc.spellpercent_text_size", config.plater.fonts.size)

        SetValue(profiles.plater, "plate_config.friendlyplayer.actorname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlyplayer.big_actorname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlyplayer.big_actortitle_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlyplayer.level_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlyplayer.percent_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlyplayer.spellname_text_size", config.plater.fonts.size)
        SetValue(profiles.plater, "plate_config.friendlyplayer.spellpercent_text_size", config.plater.fonts.size)
    end

    if config.plater.friendly then
        SetValue(profiles.plater, "auto_toggle_friendly_enabled", true)
        SetValue(profiles.plater, "auto_toggle_friendly", {
            party = true,
            arena = false,
            raid = true,
            cities = false,
            world = false
        })
    end

    if config.plater.biggerMark then
        SetValue(profiles.plater, "indicator_raidmark_scale", 1.5)
    end

    Plater.RefreshDBUpvalues()
    Plater.UpdateAllPlates()
    Plater.RefreshAutoToggle()
end

function Tweaks:ApplyTimelineRemindersConfig()
    if not TimelineReminders or not LiquidRemindersSaved or not LUI.db.global.atrocityUI.timelineReminders.enabled then return end

    local frameSettings = LiquidRemindersSaved.LiquidUI.frameSettings
    SetValue(frameSettings.BAR_ANCHOR.points, "offsetX", -400)
    SetValue(frameSettings.BAR_ANCHOR.points, "offsetY", 121)
    SetValue(frameSettings.CIRCLE_ANCHOR.points, "offsetX", 0)
    SetValue(frameSettings.CIRCLE_ANCHOR.points, "offsetY", -80)
    SetValue(frameSettings.ICON_ANCHOR.points, "offsetX", 400)
    SetValue(frameSettings.ICON_ANCHOR.points, "offsetY", 121)
    SetValue(frameSettings.TEXT_ANCHOR.points, "offsetX", 0)
    SetValue(frameSettings.TEXT_ANCHOR.points, "offsetY", 350)
end

function Tweaks:ApplyWarpDepleteConfig()
    if not WarpDepleteDB then return end

    local config = LUI.db.global.atrocityUI

    if LUI.db.global.scaleFactor then
        SetValue(profiles.warpDeplete, "frameScale", LUI.db.global.scaleFactor)
    end

    if config.fonts.resize then
        SetValue(profiles.warpDeplete, "objectivesFontSize", config.fonts.size)
        SetValue(profiles.warpDeplete, "keyFontSize", config.fonts.size)
        SetValue(profiles.warpDeplete, "bar1FontSize", config.fonts.size)
        SetValue(profiles.warpDeplete, "bar2FontSize", config.fonts.size)
        SetValue(profiles.warpDeplete, "bar3FontSize", config.fonts.size)
        SetValue(profiles.warpDeplete, "timerFontSize", 24) -- default to big font for clock
        SetValue(profiles.warpDeplete, "keyDetailsFontSize", config.fonts.size)
        SetValue(profiles.warpDeplete, "deathsFontSize", config.fonts.size)
        SetValue(profiles.warpDeplete, "forcesFontSize", config.fonts.size)
    end

    if config.elvUI.minimap then
        SetValue(profiles.warpDeplete, "frameY", 170)
    end
end

--- Hide the text of CDM bars when the value is zero.
function Tweaks:TweakACDM()
    if not Ayije_CDM or not Ayije_CDM.TAGS then return end

    local config = LUI.db.global.atrocityUI

    if config.acdm.hideWhenZero then
        self:Hook(Ayije_CDM.TAGS, "UpdateTagText", function(_, textFrame)
            if not textFrame or not textFrame.text or self:IsHooked(textFrame.text, "SetFormattedText") then return end
            self:SecureHook(textFrame.text, "SetFormattedText", function(_, text, value)
                if text == "%d" then
                    textFrame.text:SetText(C_StringUtil.TruncateWhenZero(value))
                end
            end)
        end)
    end
end

local TIER_1 = "|A:Professions-ChatIcon-Quality-12-Tier1:20:20|a"
local TIER_2 = "|A:Professions-ChatIcon-Quality-12-Tier2:20:20|a"
local ENCHANT_MAP = {
    -- Helm
    ["Blessing of Speed"] = {
        [TIER_1] = "+9 Speed",
        [TIER_2] = "+13 Speed",
    },
    ["Empowered Blessing of Speed"] = {
        [TIER_1] = "+17 Speed",
        [TIER_2] = "+22 Speed",
    },
    ["Hex of Leeching"] = {
        [TIER_1] = "+22 Leech",
        [TIER_2] = "+33 Leech",
    },
    ["Empowered Hex of Leeching"] = {
        [TIER_1] = "+44 Leech",
        [TIER_2] = "+55 Leech",
    },
    ["Rune of Avoidance"] = {
        [TIER_1] = "+15 Avoid",
        [TIER_2] = "+22 Avoid",
    },
    ["Empowered Rune of Avoidance"] = {
        [TIER_1] = "+30 Avoid",
        [TIER_2] = "+37 Avoid",
    },
    -- Shoulders
    ["Flight of the Eagle"] = {
        [TIER_1] = "+26 Speed",
        [TIER_2] = "+39 Speed",
    },
    ["Akil'zon's Swiftness"] = {
        [TIER_1] = "+52 Speed",
        [TIER_2] = "+65 Speed",
    },
    ["Thalassian Recovery"] = {
        [TIER_1] = "+66 Leech",
        [TIER_2] = "+99 Leech",
    },
    ["Silvermoon's Mending"] = {
        [TIER_1] = "+132 Leech",
        [TIER_2] = "+166 Leech",
    },
    ["Nature's Grace"] = {
        [TIER_1] = "+44 Avoid",
        [TIER_2] = "+67 Avoid",
    },
    ["Amirdrassil's Grace"] = {
        [TIER_1] = "+89 Avoid",
        [TIER_2] = "+111 Avoid",
    },
    -- Chest
    ["Mark of Nalorakk"] = {
        [TIER_1] = "+32 Str +93 Stam",
        [TIER_2] = "+40 Str +116 Stam",
    },
    ["Mark of the Magister"] = {
        [TIER_1] = "+32 Int 2% Mana",
        [TIER_2] = "+40 Int 5% Mana",
    },
    ["Mark of the Rootwarden"] = {
        [TIER_1] = "+32 Agi +12 Speed",
        [TIER_2] = "+40 Agi +15 Speed",
    },
    ["Mark of the Worldsoul"] = {
        [TIER_1] = "+36 Stats",
        [TIER_2] = "+50 Stats",
    },
    -- Legs
    ["+32 Agility/Strength & +70 Stamina"] = "+32 Agi/Str +70 Stam",
    ["+41 Agility/Strength & +115 Stamina"] = "+41 Agi/Str +115 Stam",
    ["+32 Agility/Strength & +16 Stamina"] = "+32 Agi/Str +16 Armor",
    ["+41 Agility/Strength & +27 Armor"] = "+41 Agi/Str +27 Armor",
    ["+32 Intellect & +70 Stamina"] = "+32 Int +70 Stam",
    ["+41 Intellect & +115 Stamina"] = "+41 Int +115 Stam",
    ["+32 Intellect & 3% Mana"] = "+32 Int 3% Mana",
    ["+41 Intellect & 4% Mana"] = "+41 Int 4% Mana",
    -- Boots
    ["Lynx's Dexterity"] = {
        [TIER_1] = "+15 Avoid +186 Stam",
        [TIER_2] = "+19 Avoid +232 Stam",
    },
    ["Farstrider's Hunt"] = {
        [TIER_1] = "+9 Speed +186 Stam",
        [TIER_2] = "+11 Speed +232 Stam",
    },
    ["Shaladrassil's Roots"] = {
        [TIER_1] = "+22 Leech +186 Stam",
        [TIER_2] = "+28 Leech +232 Stam",
    },
    -- Rings
    ["Nature's Wrath"] = {
        [TIER_1] = "+22 Crit",
        [TIER_2] = "+24 Crit",
    },
    ["Nature's Fury"] = {
        [TIER_1] = "+27 Crit",
        [TIER_2] = "+29 Crit"
    },
    ["Amani Mastery"] = {
        [TIER_1] = "+22 Mastery",
        [TIER_2] = "+24 Mastery",
    },
    ["Zul'jin's Mastery"] = {
        [TIER_1] = "+27 Mastery",
        [TIER_2] = "+29 Mastery",
    },
    ["Thalassian Haste"] = {
        [TIER_1] = "+22 Haste",
        [TIER_2] = "+24 Haste",
    },
    ["Silvermoon's Alacrity"] = {
        [TIER_1] = "+27 Haste",
        [TIER_2] = "+29 Haste",
    },
    ["Thalassian Versatility"] = {
        [TIER_1] = "+22 Vers",
        [TIER_2] = "+24 Vers",
    },
    ["Silvermoon's Tenacity"] = {
        [TIER_1] = "+27 Vers",
        [TIER_2] = "+29 Vers",
    },
    ["Eyes of the Eagle"] = "Crit Effect",
    -- Weapons
    ["Acuity of the Ren'dorei"] = "Acuity",
    ["Flames of the Sin'dorei"] = "Flames",
}

function Tweaks:TweakElvUI()
    if not ElvUI then return end
    local E = unpack(ElvUI)

    -- Add the "classcolor:target" tag to ElvUI since they removed it but it still
    -- seems to function just fine.
    E:AddTag("classcolor:target", "UNIT_TARGET", function(unit)
        local unitTarget = unit .. "target"
        if UnitExists(unitTarget) then
            return _TAGS.classcolor(unitTarget)
        end
    end)

    -- Remove "Enchant XYZ - " from enchant names on the character screen.
    self:Hook(E, "InspectGearSlot", function(_, line, lineText, slotInfo)
        local enchant = slotInfo.enchantTextReal
        if enchant then
            local color1, color2 = strmatch(enchant, "(|cn.-:).-(|r)")
            local quality = strmatch(enchant, "%s?(|A.-|a)")
            local text = gsub(gsub(gsub(enchant, "%s?|A.-|a", ""), "|cn.-:(.-)|r", "%1"), "Enchant %a+ %- ", "")
            if ENCHANT_MAP[text] then
                text = ENCHANT_MAP[text]
                if type(text) == "table" then
                    text = text[quality]
                end
            end
            local shortStrip = gsub(text, "& ?", "")
            local shortAbbrev = E.db.general.itemLevel.enchantAbbrev and gsub(shortStrip, "(%w%w%w)%w+", "%1")
            local truncated = string.utf8sub(shortAbbrev or shortStrip, 1, 21) ---@diagnostic disable-line: undefined-field
            slotInfo.enchantText = format("%s%s%s", color1 or "", text, color2 or "")
            slotInfo.enchantTextShort = format("%s%s%s", color1 or "", truncated, color2 or "")
        end
    end)
end

function Tweaks:ApplyAUIConfig()
    self:ApplyAtrocityEssentialsConfig()
    self:ApplyBigWigsConfig()
    self:ApplyBuffRemindersConfig()
    self:ApplyDetailsConfig()
    self:ApplyElvUIConfig()
    self:ApplyPlaterConfig()
    self:ApplyTimelineRemindersConfig()
    self:ApplyWarpDepleteConfig()

    ReloadUI()
end

function Tweaks:OnInitialize()
    self:LoadProfiles()
end

function Tweaks:OnEnable()
    self:TweakACDM()
    self:TweakElvUI()
end

function Tweaks:OnDisable()
    self:UnhookAll()
end
