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

function A_TEST()
    TEST = CreateFrame("DressUpModel", nil, UIParent, "WardrobeItemsModelTemplate")
    TEST:SetPoint("CENTER")
    TEST:SetAutoDress(false);
    local lightValues = { omnidirectional = false, point = CreateVector3D(-1, 1, -1), ambientIntensity = 1.05, ambientColor = CreateColor(1, 1, 1), diffuseIntensity = 0, diffuseColor = CreateColor(1, 1, 1) };
    local enabled = true;
    TEST:SetLight(enabled, lightValues);
    TEST.desaturated = false;
    TEST:SetUnit("player")
    --TEST:SetShown(true)
    --A_Model_ApplyUICamera(TEST, 236)
    TEST.cameraID = 236 -- Head

end

function B_TEST(appearance_id)
    return app.GetAppearanceCameraID(appearance_id)
end


--[[ local function OnEvent(self, event, unit)
	m:SetUnit(unit)
	m:TryOn(7545)
end

local f = CreateFrame("Frame")
f:RegisterUnitEvent("UNIT_MODEL_CHANGED", "player")
f:SetScript("OnEvent", OnEvent) ]]