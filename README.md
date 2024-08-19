## Details On Zone Changed

```lua
if Details.zone_type == "party" then
    LUI:TogglePanel(true)

    if Details:GetInstance(2):IsStarted() then
        Details:GetInstance(2):SetDisplay(
            DETAILS_SEGMENTID_OVERALL,
            DETAILS_ATTRIBUTE_DAMAGE,
            DETAILS_SUBATTRIBUTE_DAMAGEDONE
        )
    end

    if Details:GetInstance(3):IsStarted() then
        Details:GetInstance(3):SetDisplay(
            DETAILS_SEGMENTID_OVERALL,
            DETAILS_ATTRIBUTE_MISC,
            DETAILS_SUBATTRIBUTE_DEATH
        )
    end
end

if Details.zone_type == "raid" then
    LUI:TogglePanel(true)

    if Details:GetInstance(2):IsStarted() then
        Details:GetInstance(2):SetDisplay(
            DETAILS_SEGMENTID_CURRENT,
            DETAILS_ATTRIBUTE_HEAL,
            DETAILS_SUBATTRIBUTE_HEALDONE
        )
    end

    if Details:GetInstance(3):IsStarted() then
        Details:GetInstance(3):SetDisplay(
            DETAILS_SEGMENTID_CURRENT,
            DETAILS_ATTRIBUTE_MISC,
            DETAILS_SUBATTRIBUTE_DEATH
        )
    end
end

if Details.zone_type == "none" then
    LUI:TogglePanel(false)

    if Details:GetInstance(2):IsStarted() then
        Details:GetInstance(2):SetDisplay(
            DETAILS_SEGMENTID_CURRENT,
            DETAILS_ATTRIBUTE_HEAL,
            DETAILS_SUBATTRIBUTE_HEALDONE
        )
    end

    if Details:GetInstance(3):IsStarted() then
        Details:GetInstance(3):SetDisplay(
            DETAILS_SEGMENTID_CURRENT,
            DETAILS_ATTRIBUTE_DAMAGE,
            DETAILS_SUBATTRIBUTE_DAMAGETAKEN
        )
    end
end

-- Always set display 1 to Current Damage Done
if Details:GetInstance(1):IsStarted() then
    Details:GetInstance(1):SetDisplay(
        DETAILS_SEGMENTID_CURRENT,
        DETAILS_ATTRIBUTE_DAMAGE,
        DETAILS_SUBATTRIBUTE_DAMAGEDONE
    )
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
