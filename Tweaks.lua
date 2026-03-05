--- @class LUI
local LUI = select(2, ...)

local profiles = {
    elv = {
        dps = {},
        healer = {}
    },
    elvPrivate = {
        dps = {},
        healer = {}
    },
    bigWigs = {},
    warpDeplete = {},
    plater = {}
}

---@param dest table[]
---@param path string
---@param value any
local function SetValue(dest, path, value)
    -- Do nothing if dest is nil
    if not dest then return end

    local keys = strsplittable(".", path);

    -- For all entries in the `dest` table...
    for j, _ in pairs(dest) do
        -- Traverse the table up to the second-to-last key
        local current = dest[j]
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

function LUI:LoadProfiles()
    -- ElvUI Base
    if ElvDB then
        local elvProfiles = ElvDB["profiles"]
        for p, _ in pairs(elvProfiles) do
            local isAUI = LUI:StartsWithIgnoreCase(p, "atrocityui")
            if isAUI then
                local isHealer = LUI:ContainsIgnoreCase(p, "healer")
                if isHealer then
                    table.insert(profiles.elv.healer, elvProfiles[p])
                else
                    table.insert(profiles.elv.dps, elvProfiles[p])
                end
            end
        end
    end

    -- ElvUI Private
    if ElvPrivateDB then
        local elvPrivateProfiles = ElvPrivateDB["profiles"]
        for p, _ in pairs(elvPrivateProfiles) do
            local isAUI = LUI:StartsWithIgnoreCase(p, "atrocityui")
            if isAUI then
                local isHealer = LUI:ContainsIgnoreCase(p, "healer")
                if isHealer then
                    table.insert(profiles.elvPrivate.healer, elvPrivateProfiles[p])
                else
                    table.insert(profiles.elvPrivate.dps, elvPrivateProfiles[p])
                end
            end
        end
    end

    -- BigWigs
    if BigWigs3DB then
        local bigWigsProfiles = BigWigs3DB["namespaces"]["BigWigs_Plugins_Bars"]["profiles"]
        for p, _ in pairs(bigWigsProfiles) do
            local isAUI = LUI:StartsWithIgnoreCase(p, "atrocityui")
            if isAUI then
                table.insert(profiles.bigWigs, bigWigsProfiles[p])
            end
        end
    end

    -- WarpDeplete
    if WarpDepleteDB then
        local warpDepleteProfiles = WarpDepleteDB["profiles"]
        for p, _ in pairs(warpDepleteProfiles) do
            local isAUI = LUI:StartsWithIgnoreCase(p, "atrocityui")
            if isAUI then
                table.insert(profiles.warpDeplete, warpDepleteProfiles[p])
            end
        end
    end

    -- Plater
    if Plater then
        local platerProfiles = Plater.db["profiles"]
        for p, _ in pairs(platerProfiles) do
            local isAUI = LUI:StartsWithIgnoreCase(p, "atrocityui")
            if isAUI then
                table.insert(profiles.plater, platerProfiles[p])
            end
        end
    end

    LUI:Debug(profiles, "LoadProfiles")
end

local sharedBarSettings = {
    ["countFont"] = "Expressway",
    ["countFontOutline"] = "OUTLINE",
    ["countFontSize"] = 14,
    ["countTextPosition"] = "BOTTOMRIGHT",
    ["countTextXOffset"] = 1,
    ["countTextYOffset"] = 1,
    ["hotkeyFont"] = "Expressway",
    ["hotkeyFontOutline"] = "OUTLINE",
    ["hotkeyFontSize"] = 14,
    ["hotkeyTextPosition"] = "TOPRIGHT",
    ["hotkeyTextXOffset"] = 1,
    ["hotkeyTextYOffset"] = -2,
    ["macroFont"] = "Expressway",
    ["macroFontOutline"] = "OUTLINE",
    ["macroFontSize"] = 14,
    ["macroTextPosition"] = "BOTTOM",
    ["macroTextXOffset"] = 0,
    ["macroTextYOffset"] = 0,
}

function ApplySharedBarSettings(profile, bar)
    for setting, value in pairs(sharedBarSettings) do
        SetValue(profile, format("actionbar.%s.%s", bar, setting), value)
    end
end

local actionbarSettings = {
    ["bar1"] = {
        ["backdrop"] = true,
        ["buttonSize"] = 30,
        ["buttonSpacing"] = 1,
        ["enabled"] = true,
        ["heightMult"] = 2,
        ["mouseover"] = true,
        ["visibility"] = "[petbattle] hide; show",
    },
    ["bar2"] = {
        ["backdrop"] = true,
        ["buttonSize"] = 40,
        ["buttonSpacing"] = 1,
        ["buttons"] = 6,
        ["buttonsPerRow"] = 6,
        ["enabled"] = true,
        ["visibility"] = "[overridebar][vehicleui][possessbar][bonusbar:5] show; hide",
    },
    ["bar3"] = {
        ["backdrop"] = true,
        ["buttonSize"] = 28,
        ["buttonSpacing"] = 1,
        ["buttons"] = 12,
        ["enabled"] = true,
        ["mouseover"] = true,
        ["visibility"] = "[petbattle] hide; show",
    },
    ["bar4"] = {
        ["backdrop"] = false,
        ["buttonSize"] = 42,
        ["buttonSpacing"] = 1,
        ["buttons"] = 12,
        ["enabled"] = true,
        ["showGrid"] = false,
        ["mouseover"] = true,
        ["visibility"] = "[petbattle] hide; show",
    },
    ["bar5"] = {
        ["backdrop"] = true,
        ["buttonSize"] = 28,
        ["buttonSpacing"] = 1,
        ["buttons"] = 12,
        ["enabled"] = true,
        ["mouseover"] = true,
        ["visibility"] = "[petbattle] hide; show",
    },
    ["bar6"] = {
        ["backdrop"] = false,
        ["buttonSize"] = 30,
        ["buttonSpacing"] = 1,
        ["buttons"] = 12,
        ["enabled"] = true,
        ["mouseover"] = true,
        ["visibility"] = "[petbattle] hide; show",
    },
    ["bar13"] = {
        ["backdrop"] = false,
        ["buttonSize"] = 42,
        ["buttonSpacing"] = 1,
        ["buttonsPerRow"] = 2,
        ["buttons"] = 12,
        ["enabled"] = true,
        ["mouseover"] = true,
        ["showGrid"] = false,
        ["visibility"] = "[petbattle] hide; show",
    },
    ["barPet"] = {
        ["backdrop"] = false,
        ["buttonSize"] = 42,
        ["buttonSpacing"] = 1,
        ["buttonsPerRow"] = 2,
        ["mouseover"] = true,
        ["point"] = "TOPLEFT",
        ["visibility"] = "[petbattle] hide; [novehicleui,pet,nooverridebar,nopossessbar] show; hide",
    },
}

function ApplyElvUIBarTweaks(profile)
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
    for bar, settings in pairs(actionbarSettings) do
        ApplySharedBarSettings(profile, bar)
        for setting, value in pairs(settings) do
            SetValue(profile, format("actionbar.%s.%s", bar, setting), value)
        end
    end

    -- Movers
    SetValue(profile, "movers.ElvAB_1", "BOTTOM,ElvUIParent,BOTTOM,0.1,3")
    SetValue(profile, "movers.ElvAB_2", "BOTTOM,ElvUIParent,BOTTOM,0.1,245")
    SetValue(profile, "movers.ElvAB_3", "BOTTOM,ElvUIParent,BOTTOM,-276,3")
    SetValue(profile, "movers.ElvAB_4", "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-3,462")
    SetValue(profile, "movers.ElvAB_5", "BOTTOM,ElvUIParent,BOTTOM,277,3")
    SetValue(profile, "movers.ElvAB_6", "BOTTOM,ElvUIParent,BOTTOM,0,36")

    local panelOffset = config.elvUI.panelWidth + 4
    SetValue(profile, "movers.ElvAB_13", format("BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,%d,3", panelOffset))
    SetValue(profile, "movers.PetAB", format("BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-%d,3", panelOffset))
end

function LUI:ApplyElvUITweaks()
    if not ElvUI then return end

    local config = self.db.global.atrocityUI

    local E = unpack(ElvUI)
    local descaledFontSize = math.floor(config.fonts.size - (config.fonts.size * (self.db.global.scaleFactor - 1)))
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
        SetValue(profiles.elv.healer, "chat.panelBackdrop", "HIDEBOTH")
        SetValue(profiles.elv.dps, "chat.fadeTabsNoBackdrop", true)
        SetValue(profiles.elv.healer, "chat.fadeTabsNoBackdrop", true)
        SetValue(profiles.elv.dps, "chat.fadeChatToggles", true)
        SetValue(profiles.elv.healer, "chat.fadeChatToggles", true)
        SetValue(profiles.elv.dps, "chat.fade", true)
        SetValue(profiles.elv.healer, "chat.fade", true)
        SetValue(profiles.elv.dps, "chat.inactivityTimer", 120)
        SetValue(profiles.elv.healer, "chat.inactivityTimer", 120)
    end

    -- DataTexts
    if config.fonts.resize then
        SetValue(profiles.elv.dps, "datatexts.fontSize", config.fonts.size)
        SetValue(profiles.elv.healer, "datatexts.fontSize", config.fonts.size)
    end

    SetValue(profiles.elv.dps, "datatexts.panels.MinimapPanel.enable", config.elvUI.minimapDataTexts)
    SetValue(profiles.elv.healer, "datatexts.panels.MinimapPanel.enable", config.elvUI.minimapDataTexts)
    SetValue(profiles.elv.dps, "datatexts.panels.MinimapPanel.backdrop", true)
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

    -- Movers
    if config.elvUI.minimap then
        SetValue(profiles.elv.dps, "movers.BNETMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-290")
        SetValue(profiles.elv.healer, "movers.BNETMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-290")

        SetValue(profiles.elv.dps, "movers.DTPanelClockMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-250")
        SetValue(profiles.elv.healer, "movers.DTPanelClockMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-3,-250")

        SetValue(profiles.elv.dps, "movers.BuffsMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-269,-3")
        SetValue(profiles.elv.healer, "movers.BuffsMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-269,-3")

        SetValue(profiles.elv.dps, "movers.DebuffsMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-269,-229")
        SetValue(profiles.elv.healer, "movers.DebuffsMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-269,-229")

        SetValue(profiles.elv.dps, "movers.QueueStatusMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-8,-210")
        SetValue(profiles.elv.healer, "movers.QueueStatusMover", "TOPRIGHT,ElvUIParent,TOPRIGHT,-8,-210")
    end

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

        local RaidMover = format("BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,3,%d", config.elvUI.panelHeight + 23)
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
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusEnabled", true)
        SetValue(profiles.elv.dps, "ElvUI_Anchor.focusParent", "ElvUF_Target")
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusParent", "ElvUF_Target")
        SetValue(profiles.elv.dps, "ElvUI_Anchor.focusPoint", "LEFT")
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusPoint", "LEFT")
        SetValue(profiles.elv.dps, "ElvUI_Anchor.focusRelative", "RIGHT")
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusRelative", "RIGHT")
        SetValue(profiles.elv.dps, "ElvUI_Anchor.focusX", 65)
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusX", 65)
        SetValue(profiles.elv.dps, "ElvUI_Anchor.focusY", 37)
        SetValue(profiles.elv.healer, "ElvUI_Anchor.focusY", 37)
    end

    -- Nicknames
    if config.elvUI.nicknames then
        SetValue(profiles.elv.dps, "unitframe.units.party.name.text_format", "[classcolor][NSNickName] [afk]")
        SetValue(profiles.elv.healer, "unitframe.units.party.name.text_format", "[classcolor][NSNickName] [afk]")

        SetValue(profiles.elv.dps, "unitframe.units.raid1.name.text_format", "[classcolor][NSNickName]")
        SetValue(profiles.elv.healer, "unitframe.units.raid1.name.text_format", "[classcolor][NSNickName]")
        SetValue(profiles.elv.dps, "unitframe.units.raid2.name.text_format", "[classcolor][NSNickName]")
        SetValue(profiles.elv.healer, "unitframe.units.raid2.name.text_format", "[classcolor][NSNickName]")
        SetValue(profiles.elv.dps, "unitframe.units.raid3.name.text_format", "[classcolor][NSNickName]")
        SetValue(profiles.elv.healer, "unitframe.units.raid3.name.text_format", "[classcolor][NSNickName]")
    end

    if config.elvUI.actionbars then
        ApplyElvUIBarTweaks(profiles.elv.dps)
        ApplyElvUIBarTweaks(profiles.elv.healer)
    end
end

function LUI:ApplyBigWigsTweaks()
    if not BigWigs3DB then return end

    local config = self.db.global.atrocityUI

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

function LUI:ApplyDetailsTweaks()
    if not Details then return end

    local config = self.db.global.atrocityUI

    -- We don't do the normal SetValue stuff for Details, because if you modify *some* profile values (like tooltip)
    -- without using the global "Details" table, the settings are not persisted.
    for _, profile in ipairs(Details:GetProfileList()) do
        local isAUI = LUI:StartsWithIgnoreCase(profile, "atrocityui")
        if isAUI then
            local dtp = Details:GetProfile(profile)

            -- Apply the profile first, so that references to Details below will resolve the correct profile.
            Details:ApplyProfile(profile)

            if self.db.global.scaleFactor then
                dtp.options_window = { scale = self.db.global.scaleFactor }
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

            -- Re-position tooltip for ultra-wide
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

function LUI:ApplyPlaterTweaks()
    if not Plater then return end

    local config = self.db.global.atrocityUI

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

    SetValue(profiles.plater, "saved_cvars.nameplateGlobalScale", config.plater.globalScale)

    Plater.RefreshDBUpvalues()
    Plater.UpdateAllPlates()
    Plater.RefreshAutoToggle()
end

function LUI:ApplyWarpDepleteTweaks()
    if not WarpDepleteDB then return end

    local config = self.db.global.atrocityUI

    if self.db.global.scaleFactor then
        SetValue(profiles.warpDeplete, "frameScale", self.db.global.scaleFactor)
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

function LUI:ApplyTweaks()
    self:LoadProfiles()

    self:ApplyElvUITweaks()
    self:ApplyBigWigsTweaks()
    self:ApplyDetailsTweaks()
    self:ApplyWarpDepleteTweaks()

    ReloadUI()
end
