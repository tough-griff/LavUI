## Details On Zone Changed

```lua
if Details.zone_type == "party" then
    if Details:GetInstance(2):IsStarted() then
        Details:GetInstance(2):SetDisplay(
            DETAILS_SEGMENTID_OVERALL,
            DETAILS_ATTRIBUTE_DAMAGE,
            DETAILS_SUBATTRIBUTE_DAMAGEDONE
        )
    end
end

if Details.zone_type == "raid" or Details.zone_type == "none" then
    if Details:GetInstance(2):IsStarted() then
        Details:GetInstance(2):SetDisplay(
            DETAILS_SEGMENTID_CURRENT,
            DETAILS_ATTRIBUTE_HEAL,
            DETAILS_SUBATTRIBUTE_HEALDONE
        )
    end
end
```

## Details On Enter Combat

```lua
LUI:TogglePanel(true)
```

## Details On Leave Combat

```lua
LUI:Delay(10, function()
        if not LUI:InCombat() then
            LUI:TogglePanel(false)
        end
end)
```
