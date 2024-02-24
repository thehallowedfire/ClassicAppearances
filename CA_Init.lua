local app_name, app = ...

if not IsAddOnLoaded("Blizzard_Collections") then
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, event, arg1)
        if event == "ADDON_LOADED" and arg1 == "Blizzard_Collections" then
            self:UnregisterEvent("ADDON_LOADED")
            app:init()
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
