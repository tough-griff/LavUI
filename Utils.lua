--- @class LUI
local LUI = select(2, ...)

--- Log data to DevTool if it's available. Useful for debugging without spamming
--- the chat.
---@param data any
---@param dataName? string
function LUI:Debug(data, dataName)
    if DevTool and data then
        DevTool:AddData(data, format("[LavUI] %s", dataName or "Debug"))
    end
end

function LUI:InCombat()
    return InCombatLockdown() or UnitAffectingCombat('player') or UnitAffectingCombat('pet')
end

---@param val string
---@param starts string
---@return boolean
function LUI:StartsWithIgnoreCase(val, starts)
    local lowerVal = string.lower(val)
    local lowerStarts = string.lower(starts)

    return string.sub(lowerVal, 1, #lowerStarts) == lowerStarts
end

---@param val string
---@param search string
---@return boolean
function LUI:ContainsIgnoreCase(val, search)
    local lowerVal = string.lower(val)
    local lowerSearch = string.lower(search)

    return string.find(lowerVal, lowerSearch, 1, true) ~= nil
end
