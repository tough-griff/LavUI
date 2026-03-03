## Details On Enter Combat

```lua
LUI:TogglePanel(true)
```

## Details On Leave Combat

```lua
C_Timer.After(10, function()
        if not LUI:InCombat() then
            LUI:TogglePanel(false)
        end
end)
```
