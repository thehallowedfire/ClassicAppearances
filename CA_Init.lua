local app_name, app = ...

-- Initialize Settings (first start)
if CA_OwnedItems == nil then
    CA_OwnedItems = {}
end
if CA_SettingsPerCharacter == nil then
    CA_SettingsPerCharacter = {}
end

if not IsAddOnLoaded("Blizzard_Collections") then
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:RegisterEvent("BANKFRAME_OPENED")
    f:RegisterEvent("MAIL_SHOW")
    f:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")

    f:SetScript("OnEvent", function(self, event, arg1)
        if event == "ADDON_LOADED" and arg1 == "Blizzard_Collections" then
            self:UnregisterEvent("ADDON_LOADED")
            app.init()
        elseif event == "MAIL_SHOW" then
            app.ScanItems(1)
        elseif event == "BANKFRAME_OPENED" then
            app.ScanItems(2)
        elseif event == "GUILDBANKBAGSLOTS_CHANGED" then
            if app.guildbank_check_time == nil or (GetTime() - app.guildbank_check_time) >= 1 then
                app.guildbank_check_time = GetTime()
                app.ScanItems(3)
            end
        end
    end)
end

-- Hack to get names for weapon categories
for i, info in pairs(app.DB.CATEGORIES) do
    if type(info[1]) ~= "string" then
        local id = info[1]
        local spell = Spell:CreateFromSpellID(id)
        spell:ContinueOnSpellLoad(function()
            local name = spell:GetSpellName()
            app.DB.CATEGORIES[i][1] = name
        end)
    end
end

app.non_filtered = true

C_Timer.After(1, function()
    local name, realm = UnitFullName("player")
    app.player_full_name = name.."-"..realm
end)

