--- @class LUI
local LUI = select(2, ...)

function LUI:GetDefaults()
    --- @type AceDB.Schema
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
                    actionbars = false,
                    databars = false,
                    disableBags = false,
                    panels = false,
                    panelWidth = 500,
                    panelHeight = 268,
                    panelBackdrop = false,
                    minimapDataTexts = false,
                    minimap = false,
                    tooltip = false,
                    unitFrames = false,
                    guildRepairs = false,
                    acceptInvitesFromGuildmates = false,
                    nicknames = false,
                },
                bigWigs = false,
                details = false,
                plater = {
                    fonts = {
                        resize = false,
                        size = 8,
                    },
                    friendly = false,
                    globalScale = 1,
                },
            },
        }
    }
end

function LUI:GetOptions()
    --- @type AceConfig.OptionsTable
    return {
        name = format("|cffffccff%s|r v%s", "LavUI", C_AddOns.GetAddOnMetadata("LavUI", "Version")),
        type = "group",
        handler = self,
        args = {
            apply = {
                order = 1000,
                name = "Apply changes",
                desc = "To apply changes, you might need to reload your UI.",
                type = "execute",
                func = function() return self:ApplyTweaks() end,
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
                    return self:ApplyTweaks()
                end,
            },
            general = {
                order = 1,
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
                                set = function(_, val) self.db.global.scaleEnabled = val end,
                                get = function() return self.db.global.scaleEnabled end,
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
                                set = function(_, val) self.db.global.scaleFactor = val end,
                                get = function() return self.db.global.scaleFactor end,
                            },
                            reminder = {
                                order = 30,
                                type = "description",
                                fontSize = "medium",
                                name = "You need to reload your UI after changing this.\n",
                            },
                        },
                    },
                },
            },
            atrocityUI = {
                order = 10,
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
                        name = "Ultra-wide Tweaks",
                        inline = true,
                        args = {
                            unitFrames = {
                                name = "Unit frame positions?",
                                desc = "On ultra-wide resolutions the unit frames are positioned " ..
                                    "incorrectly. Should we fix them?",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.unitFrames = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.unitFrames end,
                            },
                            bigWigs = {
                                name = "BigWigs Bars?",
                                desc = "Re-position BigWigs bars for ultra-wide, and set max bars shown to 5.",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.bigWigs = val end,
                                get = function() return self.db.global.atrocityUI.bigWigs end,
                            },
                            details = {
                                name = "Details Tweaks?",
                                desc = "Fixes the details tooltip anchor for ultra-wide.",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.details = val end,
                                get = function() return self.db.global.atrocityUI.details end,
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
                                set = function(_, val) self.db.global.atrocityUI.fonts.resize = val end,
                                get = function() return self.db.global.atrocityUI.fonts.resize end,
                            },
                            size = {
                                name = "Desired font size",
                                desc = "If 'Change font size' is enabled, what size should we use?",
                                type = "range",
                                min = 8,
                                max = 30,
                                step = 1,
                                disabled = function() return not self.db.global.atrocityUI.fonts.resize end,
                                set = function(_, val) self.db.global.atrocityUI.fonts.size = val end,
                                get = function() return self.db.global.atrocityUI.fonts.size end,
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
                                    "This will require changing your keybindings as well.",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.actionbars = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.actionbars end
                            },
                            databars = {
                                name = "Data bars?",
                                desc = "Should we increase the size of the experience bar when shown?",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.databars = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.databars end,
                            },
                            disableBags = {
                                name = "Disable bags?",
                                desc = "Should ElvUI bags be disabled? I use Baganator instead.",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.disableBags = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.disableBags end,
                            },
                            panels = {
                                name = "Bigger chat panels?",
                                desc = "Should we increase the size of the chat and damage meter panels?",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.panels = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.panels end,
                            },
                            panelWidth = {
                                name = "Chat panel width",
                                desc = "If 'Bigger chat panels' is enabled, how wide should they be?",
                                type = "range",
                                min = 400,
                                max = 800,
                                step = 1,
                                disabled = function() return not self.db.global.atrocityUI.elvUI.panels end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.panelWidth = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.panelWidth end,
                            },
                            panelHeight = {
                                name = "Chat panel height",
                                desc = "If 'Bigger chat panels' is enabled, how tall should they be?",
                                type = "range",
                                min = 214,
                                max = 300,
                                step = 1,
                                disabled = function() return not self.db.global.atrocityUI.elvUI.panels end,
                                set = function(_, val) self.db.global.atrocityUI.elvUI.panelHeight = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.panelHeight end,
                            },
                            panelBackdrop = {
                                name = "Disable chat panel backdrop?",
                                desc = "Should we disable the backdrop on chat panels?",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.panelBackdrop = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.panelBackdrop end,
                            },
                            minimapDataTexts = {
                                name = "Minimap data texts?",
                                desc = "Should we enable the data texts under the minimap?",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.minimapDataTexts = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.minimapDataTexts end,
                            },
                            minimap = {
                                name = "Bigger minimap?",
                                desc = "Should we make the minimap bigger?",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.minimap = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.minimap end,
                            },
                            tooltip = {
                                name = "Tooltip tweaks?",
                                desc = "Should we disable item count and set the modifier key to SHIFT?",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.tooltip = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.tooltip end,
                            },
                            guildRepairs = {
                                name = "Use guild repairs?",
                                desc = "Should we auto-repair with guild funds?",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.guildRepairs = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.guildRepairs end,
                            },
                            autoAcceptInvites = {
                                name = "Auto accept invites?",
                                desc = "Should we automatically accept group invites from guild mates and friends?",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.autoAcceptInvites = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.autoAcceptInvites end,
                            },
                            nicknames = {
                                name = "Use nicknames?",
                                desc = "Should we use nicknames on unit frames?",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.elvUI.nicknames = val end,
                                get = function() return self.db.global.atrocityUI.elvUI.nicknames end,
                            }
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
                                set = function(_, val) self.db.global.atrocityUI.plater.fonts.resize = val end,
                                get = function() return self.db.global.atrocityUI.plater.fonts.resize end,
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
                                set = function(_, val) self.db.global.atrocityUI.plater.fonts.size = val end,
                                get = function() return self.db.global.atrocityUI.plater.fonts.size end,
                            },
                            friendly = {
                                order = 20,
                                name = "Friendly plates?",
                                desc = "Should we auto-enable friendly nameplates in dungeons and raids?",
                                type = "toggle",
                                set = function(_, val) self.db.global.atrocityUI.plater.friendly = val end,
                                get = function() return self.db.global.atrocityUI.plater.friendly end,
                            },
                            globalScale = {
                                order = 30,
                                name = "Global Scale",
                                desc = "Should we apply a custom scale to Plater frames?",
                                type = "range",
                                min = 1.00,
                                max = 2.00,
                                step = 0.01,
                                isPercent = true,
                                set = function(_, val) self.db.global.atrocityUI.plater.globalScale = val end,
                                get = function() return self.db.global.atrocityUI.plater.globalScale end,
                            },
                        },
                    },
                },
            },
        },
    }
end
