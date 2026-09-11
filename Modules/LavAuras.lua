---@class LUI
local LUI = select(2, ...)
---@class LA: AceModule, AceEvent-3.0
local LA = LUI:NewModule("LavAuras", "AceEvent-3.0")

function LA:ENCOUNTER_START(_, encounterID)
    if encounterID == 3420 then -- Sszorak
        if GetCVar("RAIDsettingsEnabled") == "1" then
            print("raidGraphicsParticleDensity = 0")
            SetCVar("raidGraphicsParticleDensity", 0)
        else
            print("graphicsParticleDensity = 0")
            SetCVar("graphicsParticleDensity", 0)
        end
    end
end

function LA:ENCOUNTER_END(_, encounterID)
    if encounterID == 3420 then -- Sszorak
        if GetCVar("RAIDsettingsEnabled") == "1" then
            SetCVar("raidGraphicsParticleDensity", self.raidGraphicsParticleDensity)
        else
            SetCVar("graphicsParticleDensity", self.graphicsParticleDensity)
        end
        print("Particle Density Restored")
    end
end

function LA:OnInitialize()
    self.raidGraphicsParticleDensity = GetCVar("raidGraphicsParticleDensity")
    self.graphicsParticleDensity = GetCVar("graphicsParticleDensity")
end

function LA:OnEnable()
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
end

function LA:OnDisable()
    self:UnregisterAllEvents()
end
