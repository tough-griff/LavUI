---@class LUI
local LUI = select(2, ...)

function LUI:GetDefaults()
    ---@type AceDB.Schema
    return {
        global = {
            scaleEnabled = false,
            scaleFactor = 1.20,
            atrocityUI = {
                fonts = {
                    resize = false,
                    size = 16,
                },
                elvUI = {
                    unitFrames = false,
                    actionbars = false,
                    autoAcceptInvites = false,
                    databars = false,
                    disableBags = false,
                    disableSkins = false,
                    guildRepairs = false,
                    minimap = false,
                    minimapDataTexts = false,
                    nicknames = false,
                    panels = false,
                    panelBackdrop = false,
                    panelHeight = 268,
                    panelWidth = 500,
                    tooltip = false,
                    unitFrameRestIcon = false,
                },
                bigWigs = false, -- ultrawide
                details = false, -- ultrawide
                plater = {
                    fonts = {
                        resize = false,
                        size = 14,
                    },
                    friendly = false,
                },
                acdm = {
                    hideWhenZero = false,
                },
                aes = {
                    disableMissingBuffs = false,
                    enableCombatCross = false,
                    disableAutomations = false,
                }
            },
        }
    }
end

function LUI:GetOptions()
    ---@class Scaling
    local Scaling = self:GetModule("Scaling")
    ---@class Tweaks
    local Tweaks = self:GetModule("Tweaks")

    ---@type AceConfig.OptionsTable
    return {
        name = format("|cffffccff%s|r v%s", "LavUI", C_AddOns.GetAddOnMetadata("LavUI", "Version")),
        type = "group",
        handler = self,
        childGroups = "tab",
        args = {
            apply = {
                order = 1000,
                name = "Apply changes",
                desc = "To apply changes, you might need to reload your UI.",
                type = "execute",
                func = function() return Tweaks:ApplyAUIConfig() end,
            },
            reset = {
                order = 1001,
                name = "Reset defaults",
                desc = "Reset configuration to the defaults.",
                type = "execute",
                confirm = true,
                confirmText = "Reset your configuration and reload UI?",
                func = function()
                    self.db:ResetDB(DEFAULT)
                    return ReloadUI()
                end,
            },
            keybindings = {
                order = 1002,
                name = "Keybindings",
                desc = "Open the keybinding menu.",
                type = "execute",
                func = function() return Settings.OpenToCategory(39, BINDING_HEADER_LUI) end,
            },
            general = {
                order = 10,
                name = "General Tweaks",
                type = "group",
                args = {
                    settings = {
                        order = 10,
                        type = "group",
                        name = "Scaling",
                        inline = true,
                        args = {
                            scaleEnabled = {
                                order = 10,
                                name = "Enable Scaling Fixes",
                                desc = "Attempts to scale frames to the desired factor directly, " ..
                                    "without modifying global scale settings.",
                                type = "toggle",
                                get = function() return self.db.global.scaleEnabled end,
                                set = function(_, val)
                                    self.db.global.scaleEnabled = val
                                    if val then Scaling:Enable() else Scaling:Disable() end
                                end,
                            },
                            scaleFactor = {
                                order = 20,
                                name = "Scale Factor",
                                desc = "A percentage multiplier used to determine how much to scale.",
                                type = "range",
                                min = 1.00,
                                max = 2.00,
                                step = 0.01,
                                isPercent = true,
                                disabled = function() return not self.db.global.scaleEnabled end,
                                get = function() return self.db.global.scaleFactor end,
                                set = function(_, val) self.db.global.scaleFactor = val end,

                            },
                            reminder = {
                                order = 30,
                                type = "description",
                                fontSize = "medium",
                                name = "You need to reload your UI after changing this.\n",
                                width = "full"
                            },
                        },
                    },
                },
            },
            atrocityUI = {
                order = 20,
                name = "AtrocityUI Tweaks",
                type = "group",
                args = {
                    heading = {
                        order = 1,
                        type = "group",
                        name = "How it Works",
                        inline = true,
                        args = {
                            description = {
                                type = "description",
                                fontSize = "medium",
                                name = "These settings are only applied when you click the " ..
                                    "`Apply changes` button above. You'll need to re-apply these " ..
                                    "settings every time you update or install AtrocityUI."
                            }
                        }
                    },
                    ultrawide = {
                        order = 10,
                        type = "group",
                        name = "Ultrawide Tweaks",
                        inline = true,
                        args = {
                            unitFrames = {
                                name = "Unit frame positions?",
                                desc = "On ultrawide resolutions the unit frames are positioned " ..
                                    "incorrectly. Should we fix them?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.elvUI.unitFrames end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.unitFrames = val end,
                            },
                            bigWigs = {
                                name = "BigWigs Bars?",
                                desc = "Re-position BigWigs bars for ultrawide, and set max bars shown to 5.",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.bigWigs end,
                                set = function(_, val) self.db.global.atrocityUI.bigWigs = val end,
                            },
                            details = {
                                name = "Details Tweaks?",
                                desc = "Fixes the details tooltip anchor for ultrawide.",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.details end,
                                set = function(_, val) self.db.global.atrocityUI.details = val end,
                            },
                        },
                    },
                    fonts = {
                        order = 20,
                        type = "group",
                        name = "Font Tweaks",
                        inline = true,
                        args = {
                            resizeFonts = {
                                name = "Change font size?",
                                desc = "Should we change the general UI font size?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.fonts.resize end,
                                set = function(_, val) self.db.global.atrocityUI.fonts.resize = val end,
                            },
                            size = {
                                name = "Desired font size",
                                desc = "If 'Change font size' is enabled, what size should we use?",
                                type = "range",
                                min = 8,
                                max = 30,
                                step = 1,
                                disabled = function() return not self.db.global.atrocityUI.fonts.resize end,
                                get = function() return self.db.global.atrocityUI.fonts.size end,
                                set = function(_, val) self.db.global.atrocityUI.fonts.size = val end,
                            },
                        },
                    },
                    elvUI = {
                        order = 30,
                        type = "group",
                        name = "ElvUI Tweaks",
                        inline = true,
                        args = {
                            actionbars = {
                                name = "Action bars?",
                                desc = "Should we use a different action bar setup that is more " ..
                                    "compatible with the base UI and other action bar addons? " ..
                                    "This will likely require changing your keybindings.",
                                type = "toggle",
                                confirm = true,
                                confirmText = "This will change your action bar layout dramatically. Are you sure?",
                                get = function() return self.db.global.atrocityUI.elvUI.actionbars end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.actionbars = val end,
                            },
                            autoAcceptInvites = {
                                name = "Auto accept invites?",
                                desc = "Should we automatically accept group invites from guild mates and friends?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.elvUI.autoAcceptInvites end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.autoAcceptInvites = val end,
                            },
                            databars = {
                                name = "Data bars?",
                                desc = "Should we increase the size of the experience bar when shown?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.elvUI.databars end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.databars = val end,
                            },
                            disableBags = {
                                name = "Disable bags?",
                                desc = "Should ElvUI bags be disabled? I use Baganator instead.",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.elvUI.disableBags end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.disableBags = val end,
                            },
                            disableSkins = {
                                name = "Disable skins?",
                                desc = "Should (most) ElvUI skins be disabled? I prefer the default " ..
                                    "blizzard UI for most frames.",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.elvUI.disableSkins end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.disableSkins = val end,
                            },
                            guildRepairs = {
                                name = "Use guild repairs?",
                                desc = "Should we auto-repair with guild funds?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.elvUI.guildRepairs end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.guildRepairs = val end,
                            },
                            minimap = {
                                name = "Bigger minimap?",
                                desc = "Should we make the minimap bigger?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.elvUI.minimap end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.minimap = val end,
                            },
                            minimapDataTexts = {
                                name = "Minimap datatexts?",
                                desc = "Should we enable the datatexts under the minimap?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.elvUI.minimapDataTexts end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.minimapDataTexts = val end,
                            },
                            nicknames = {
                                name = "Use nicknames?",
                                desc = "Should we use nicknames on unit frames?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.elvUI.nicknames end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.nicknames = val end,
                            },
                            panels = {
                                name = "Chat Panels",
                                type = "group",
                                inline = true,
                                args = {
                                    panels = {
                                        name = "Bigger chat panels?",
                                        desc = "Should we increase the size of the chat and damage meter panels?",
                                        type = "toggle",
                                        get = function() return self.db.global.atrocityUI.elvUI.panels end,
                                        set = function(_, val) self.db.global.atrocityUI.elvUI.panels = val end,
                                    },
                                    panelWidth = {
                                        name = "Chat panel width",
                                        desc = "If 'Bigger chat panels' is enabled, how wide should they be?",
                                        type = "range",
                                        min = 400,
                                        max = 800,
                                        step = 1,
                                        disabled = function() return not self.db.global.atrocityUI.elvUI.panels end,
                                        get = function() return self.db.global.atrocityUI.elvUI.panelWidth end,
                                        set = function(_, val) self.db.global.atrocityUI.elvUI.panelWidth = val end,
                                    },
                                    panelHeight = {
                                        name = "Chat panel height",
                                        desc = "If 'Bigger chat panels' is enabled, how tall should they be?",
                                        type = "range",
                                        min = 214,
                                        max = 300,
                                        step = 1,
                                        disabled = function() return not self.db.global.atrocityUI.elvUI.panels end,
                                        get = function() return self.db.global.atrocityUI.elvUI.panelHeight end,
                                        set = function(_, val) self.db.global.atrocityUI.elvUI.panelHeight = val end,
                                    },
                                    panelBackdrop = {
                                        name = "Disable backdrop?",
                                        desc = "Should we disable the backdrop on chat panels?",
                                        type = "toggle",
                                        get = function() return self.db.global.atrocityUI.elvUI.panelBackdrop end,
                                        set = function(_, val) self.db.global.atrocityUI.elvUI.panelBackdrop = val end,
                                    },
                                },
                            },
                            tooltip = {
                                name = "Tooltip tweaks?",
                                desc = "Should we disable item count?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.elvUI.tooltip end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.tooltip = val end,
                            },
                            unitFrameRestIcon = {
                                name = "Rest icon?",
                                desc = "Should we show the rest icon on the player frame when rested?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.elvUI.unitFrameRestIcon end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.unitFrameRestIcon = val end,
                            },
                        },
                    },
                    plater = {
                        order = 40,
                        type = "group",
                        name = "Plater Tweaks",
                        inline = true,
                        args = {
                            resizeFonts = {
                                order = 1,
                                name = "Change font size?",
                                desc = "Should we change font size for Plater nameplates?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.plater.fonts.resize end,
                                set = function(_, val) self.db.global.atrocityUI.plater.fonts.resize = val end,
                            },
                            size = {
                                order = 10,
                                name = "Desired font size",
                                desc = "If 'Change font size' is enabled, what size should we use?",
                                type = "range",
                                min = 6,
                                max = 30,
                                step = 1,
                                disabled = function() return not self.db.global.atrocityUI.plater.fonts.resize end,
                                get = function() return self.db.global.atrocityUI.plater.fonts.size end,
                                set = function(_, val) self.db.global.atrocityUI.plater.fonts.size = val end,
                            },
                            friendly = {
                                order = 20,
                                name = "Friendly plates?",
                                desc = "Should we auto-enable friendly nameplates in dungeons and raids?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.plater.friendly end,
                                set = function(_, val) self.db.global.atrocityUI.plater.friendly = val end,
                            },
                        },
                    },
                    acdm = {
                        order = 50,
                        type = "group",
                        name = "Ayije CDM Tweaks",
                        inline = true,
                        args = {
                            hideWhenZero = {
                                name = "Hide when zero?",
                                desc = "Should we hide the CDM power text when zero? Prevents OLED burnin",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.acdm.hideWhenZero end,
                                set = function(_, val) self.db.global.atrocityUI.acdm.hideWhenZero = val end,
                            },
                        },
                    },
                    aes = {
                        order = 60,
                        type = "group",
                        name = "AtrocityEssentials Tweaks",
                        inline = true,
                        args = {
                            disableMissingBuffs = {
                                name = "Disable missing buffs?",
                                desc = "Should we disable the missing buff icons? I use BuffReminders instead.",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.aes.disableMissingBuffs end,
                                set = function(_, val) self.db.global.atrocityUI.aes.disableMissingBuffs = val end,
                            },
                            enableCombatCross = {
                                name = "Enable combat cross?",
                                desc = "Should we enable the combat cross?",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.aes.enableCombatCross end,
                                set = function(_, val) self.db.global.atrocityUI.aes.enableCombatCross = val end,
                            },
                            disableAutomations = {
                                name = "Disable some automations?",
                                width = "double",
                                desc = "Disables a few automations.\n\n" ..
                                    "1. Talking Head, I manage this with Plumber.\n" ..
                                    "2. Auto quest accept/turn in, I manage this with WindTools.",
                                type = "toggle",
                                get = function() return self.db.global.atrocityUI.aes.disableAutomations end,
                                set = function(_, val) self.db.global.atrocityUI.aes.disableAutomations = val end,
                            }
                        },
                    },
                },
            },
        },
    }
end
