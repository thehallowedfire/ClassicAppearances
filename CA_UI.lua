local app_name, app = ...

--A temp
--WARDROBE = "Модели"

local function HideWardrobeCollectionJournal(self)
    if WardrobeCollectionFrame:IsShown() then
        WardrobeCollectionFrame:Hide()
    end
end

function app.init()
    local tab_id = CollectionsJournal.numTabs + 1;
    local tab = CreateFrame("Button", "$parentTab"..tab_id, CollectionsJournal, "CharacterFrameTabButtonTemplate", tab_id);
    tab:SetPoint("LEFT", "$parentTab" .. (tab_id-1), "RIGHT", -16, 0);
    tab:SetText(WARDROBE);
    PanelTemplates_SetNumTabs(CollectionsJournal, tab_id);
    PanelTemplates_SetTab(CollectionsJournal, tonumber(GetCVar("petJournalTab")) or 1);
    tab:SetScript("OnClick", function(self)
        PanelTemplates_SetTab(self:GetParent(), self:GetID());
        CollectionsJournal_UpdateSelectedTab(self:GetParent());
        WardrobeCollectionFrame:SetShown(true)
        PlaySound(SOUNDKIT.UI_TOYBOX_TABS);
    end)
    MountJournal:HookScript("OnShow", HideWardrobeCollectionJournal)
    PetJournal:HookScript("OnShow", HideWardrobeCollectionJournal)
    ToyBox:HookScript("OnShow", HideWardrobeCollectionJournal)
    HeirloomsJournal:HookScript("OnShow", HideWardrobeCollectionJournal)
    WardrobeCollectionFrame = CreateFrame("Frame", "WardrobeCollectionFrame", CollectionsJournal, "WardrobeCollectionFrameTemplate")
end
