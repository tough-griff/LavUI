local E, L, V, P, G = unpack(ElvUI)
local addonName, addon = ...

local _G = _G
local LavUI = E:NewModule(addonName)
local Utils = {}
V.LUI = {}
P.LUI = {}
G.LUI = {}

addon[1] = LavUI
addon[2] = Utils
addon[3] = E
addon[4] = L
addon[5] = V.LUI
addon[6] = P.LUI
addon[7] = G.LUI
_G[addonName] = addon
_G["LUI"] = Utils

function LavUI:InsertOptions()
end

function LavUI:Initialize()
    E.Libs.EP:RegisterPlugin(addonName, LavUI:InsertOptions())
end

E:RegisterModule(addonName)
