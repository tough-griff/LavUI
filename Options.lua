---@class LUI
local LUI = select(2, ...)

function LUI:GetDefaults()
    ---@type AceDB.Schema
    return {
        global = {
            scaleEnabled = false,
            scaleFactor = 1.20,
            hideLootRolls = false,
            -- Size and colours are read live from AtrocityEssentials, so the
            -- only things worth saving are which window we seat and where.
            chatPanel = {
                enabled = false,
                -- No default window on purpose. Blizzard's first three -- the
                -- dock primary, the combat log and Voice -- are all unseatable,
                -- and which index holds a usable window is up to the user's own
                -- layout. Unset reads as "no chat window selected" until picked.
                frameID = nil,
                anchorFrom = "BOTTOMRIGHT",
                anchorTo = "BOTTOMRIGHT",
                xOffset = -1,
                yOffset = 1,
                hideInCombat = false,
            },
        }
    }
end

function LUI:GetOptions()
    ---@class ChatPanel
    local ChatPanel = self:GetModule("ChatPanel")
    ---@class ChatSetup
    local ChatSetup = self:GetModule("ChatSetup")
    ---@class HideLootRolls
    local HideLootRolls = self:GetModule("HideLootRolls")
    ---@class Scaling
    local Scaling = self:GetModule("Scaling")

    ---@type AceConfig.OptionsTable
    return {
        name = format("|cffffccff%s|r v%s", "LavUI", C_AddOns.GetAddOnMetadata("LavUI", "Version")),
        type = "group",
        handler = self,
        childGroups = "tab",
        args = {
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
                    scaling = {
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
                    hideLootRolls = {
                        order = 20,
                        name = "Autohide Loot Roll window",
                        desc = "Automatically hide the loot roll frame after 60 seconds.",
                        type = "toggle",
                        get = function() return self.db.global.hideLootRolls end,
                        set = function(_, val)
                            self.db.global.hideLootRolls = val
                            if val then HideLootRolls:Enable() else HideLootRolls:Disable() end
                        end,
                        width = "full",
                    },
                    chatPanel = {
                        order = 30,
                        type = "group",
                        name = "Second Chat Panel",
                        inline = true,
                        args = {
                            description = {
                                order = 1,
                                type = "description",
                                fontSize = "medium",
                                name = "Gives an undocked chat window the same panel treatment " ..
                                    "AtrocityEssentials gives its own: matching size, matching backdrop " ..
                                    "and the active-tab styling its docked tab gets.\n\n" ..
                                    "Only undocked windows can be seated, so the list below is empty " ..
                                    "until you right-click a chat tab and undock it. General, the " ..
                                    "combat log and Voice never appear.\n\n" ..
                                    "Size and colours are read from AtrocityEssentials directly, so " ..
                                    "there is nothing here to keep in sync. Drag it with the " ..
                                    "EllesmereUI mover.\n",
                                width = "full",
                            },
                            enabled = {
                                order = 10,
                                name = "Enable second chat panel",
                                desc = "The window must be undocked, and must not be the one " ..
                                    "AtrocityEssentials has already seated in its own panel.",
                                type = "toggle",
                                get = function() return self.db.global.chatPanel.enabled end,
                                set = function(_, val)
                                    self.db.global.chatPanel.enabled = val
                                    if val then ChatPanel:Enable() else ChatPanel:Disable() end
                                end,
                                width = "full",
                            },
                            hideInCombat = {
                                order = 15,
                                name = "Hide in combat",
                                desc = "Hides this panel -- and any damage meters via the same " ..
                                    "Toggle Right Panel keybind -- when you enter combat, and " ..
                                    "shows them again about 10 seconds after combat ends.",
                                type = "toggle",
                                disabled = function() return not self.db.global.chatPanel.enabled end,
                                get = function() return self.db.global.chatPanel.hideInCombat end,
                                set = function(_, val) self.db.global.chatPanel.hideInCombat = val end,
                                width = "full",
                            },
                            frameID = {
                                order = 20,
                                name = "Chat window",
                                desc = "Which chat window to seat in the panel.",
                                type = "select",
                                disabled = function() return not self.db.global.chatPanel.enabled end,
                                values = function()
                                    -- Only what can actually be seated, so the
                                    -- list cannot offer something that then
                                    -- refuses. Rules live on the module.
                                    local windows = {}
                                    for i = 1, NUM_CHAT_WINDOWS do
                                        local name = GetChatWindowInfo(i)
                                        if name and name ~= "" and ChatPanel:IsSeatable(_G["ChatFrame" .. i]) then
                                            windows[i] = format("%d. %s", i, name)
                                        end
                                    end
                                    return windows
                                end,
                                get = function() return self.db.global.chatPanel.frameID end,
                                set = function(_, val)
                                    -- Let go of the old window before claiming
                                    -- the new one, or it keeps our geometry.
                                    ChatPanel:Release()
                                    self.db.global.chatPanel.frameID = val
                                    ChatPanel:UpdatePanel()
                                end,
                            },
                            status = {
                                order = 30,
                                type = "description",
                                fontSize = "medium",
                                name = function()
                                    if not self.db.global.chatPanel.enabled then return "" end
                                    local reason = ChatPanel.blockedReason
                                    if reason then return format("|cffff8080Not seated:|r %s.", reason) end
                                    return "|cff80ff80Seated.|r"
                                end,
                                width = "full",
                            },
                        },
                    },
                    chatSetup = {
                        order = 40,
                        type = "group",
                        name = "Chat Window Setup",
                        inline = true,
                        args = {
                            description = {
                                order = 1,
                                type = "description",
                                fontSize = "medium",
                                name = "Resets your chat windows and re-applies the message group / " ..
                                    "channel layout defined in Modules\\ChatSetup.lua. Edit that file " ..
                                    "to change which groups and channels land on which tab.\n",
                                width = "full",
                            },
                            run = {
                                order = 10,
                                name = "Configure Chat Windows",
                                desc = "Reset chat windows and apply the layout from ChatSetup.lua.",
                                type = "execute",
                                confirm = true,
                                confirmText = "This resets all chat windows to reapply your configured " ..
                                    "layout. Continue?",
                                func = function() ChatSetup:Configure() end,
                            },
                        },
                    },
                },
            },
        },
    }
end
