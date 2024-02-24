local app_name, app = ...

local MAIN_HAND_INV_TYPE = 21;
local OFF_HAND_INV_TYPE = 22;
local RANGED_INV_TYPE = 15;
local TAB_ITEMS = 1;
local TAB_SETS = 2;
local TABS_MAX_WIDTH = 185;

local WARDROBE_MODEL_SETUP = {
	["HEADSLOT"] 		= { useTransmogSkin = false, useTransmogChoices = false, obeyHideInTransmogFlag = false, slots = { CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = false } },
	["SHOULDERSLOT"]	= { useTransmogSkin = true,  useTransmogChoices = true,  obeyHideInTransmogFlag = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["BACKSLOT"]		= { useTransmogSkin = true,  useTransmogChoices = true,  obeyHideInTransmogFlag = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["CHESTSLOT"]		= { useTransmogSkin = true,  useTransmogChoices = true,  obeyHideInTransmogFlag = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["TABARDSLOT"]		= { useTransmogSkin = true,  useTransmogChoices = true,  obeyHideInTransmogFlag = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["SHIRTSLOT"]		= { useTransmogSkin = true,  useTransmogChoices = true,  obeyHideInTransmogFlag = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["WRISTSLOT"]		= { useTransmogSkin = true,  useTransmogChoices = true,  obeyHideInTransmogFlag = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["HANDSSLOT"]		= { useTransmogSkin = false, useTransmogChoices = true,  obeyHideInTransmogFlag = true,  slots = { CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = true,  FEETSLOT = true,  HEADSLOT = true  } },
	["WAISTSLOT"]		= { useTransmogSkin = true,  useTransmogChoices = true,  obeyHideInTransmogFlag = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["LEGSSLOT"]		= { useTransmogSkin = true,  useTransmogChoices = true,  obeyHideInTransmogFlag = true,  slots = { CHESTSLOT = false, HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = true  } },
	["FEETSLOT"]		= { useTransmogSkin = false, useTransmogChoices = true,  obeyHideInTransmogFlag = true,  slots = { CHESTSLOT = true,  HANDSSLOT = true,  LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true  } },
}

local WARDROBE_MODEL_SETUP_GEAR = {
	["CHESTSLOT"] = 78420,
	["LEGSSLOT"] = 78425,
	["FEETSLOT"] = 78427,
	["HANDSSLOT"] = 78426,
	["HEADSLOT"] = 78416,
}

CA_WardrobeCollectionFrameMixin = { }

function CA_WardrobeCollectionFrameMixin:OnLoad()
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, TAB_ITEMS);
	PanelTemplates_ResizeTabsToFit(self, TABS_MAX_WIDTH);
	self.selectedCollectionTab = TAB_ITEMS;

	--[[ SetPortraitToTexture(CollectionsJournal.portrait, "Interface\\Icons\\inv_misc_enggizmos_19"); ]]
end

function CA_WardrobeCollectionFrameMixin:ClickTab(tab)
	self:SetTab(tab:GetID());
	PanelTemplates_ResizeTabsToFit(WardrobeCollectionFrame, TABS_MAX_WIDTH);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function CA_WardrobeCollectionFrameMixin:SetTab(tabID)
	PanelTemplates_SetTab(self, tabID);
	self.selectedCollectionTab = tabID;
	if tabID == TAB_ITEMS then
		-- self.activeFrame = self.ItemsCollectionFrame;
		self.ItemsCollectionFrame:Show();
		self.SetsCollectionFrame:Hide();
		self.SearchBox:ClearAllPoints();
		self.SearchBox:SetPoint("TOPRIGHT", -107, -35);
		self.SearchBox:SetWidth(115);
		--[[ local enableSearchAndFilter = self.ItemsCollectionFrame.transmogLocation and self.ItemsCollectionFrame.transmogLocation:IsAppearance() ]]
		--[[ self.SearchBox:SetEnabled(enableSearchAndFilter); ]]
		--[[ self.FilterButton:Show();
		self.FilterButton:SetEnabled(enableSearchAndFilter); ]]
	elseif tabID == TAB_SETS then
		self.ItemsCollectionFrame:Hide();
		self.SearchBox:ClearAllPoints();
		-- self.activeFrame = self.SetsCollectionFrame;
		self.SearchBox:SetPoint("TOPLEFT", 19, -69);
		self.SearchBox:SetWidth(145);
		--[[ self.FilterButton:Show();
		self.FilterButton:SetEnabled(true); ]]
		--[[ self.SearchBox:SetEnabled(true); ]]
		self.SetsCollectionFrame:SetShown(true);
	end
	--[[ WardrobeResetFiltersButton_UpdateVisibility(); ]]
	--[[ WardrobeFrame:TriggerEvent(WardrobeFrameMixin.Event.OnCollectionTabChanged); ]]
end

function CA_WardrobeCollectionFrameMixin:OnShow()
	SetPortraitToTexture(self:GetParent().portrait, "Interface\\Icons\\inv_chest_cloth_17");
	self:SetTab(self.selectedCollectionTab);
end

function CA_WardrobeCollectionFrameMixin:OnHide()
	for i, frame in ipairs(self.ContentFrames) do
		frame:Hide();
	end
end

function CA_WardrobeCollectionFrameMixin:OnKeyDown(key)
	print("CA_WardrobeCollectionFrameMixin:OnKeyDown", KEY)
	--[[ if self.tooltipCycle and key == WARDROBE_CYCLE_KEY then
		self:SetPropagateKeyboardInput(false);
		if IsShiftKeyDown() then
			self.tooltipSourceIndex = self.tooltipSourceIndex - 1;
		else
			self.tooltipSourceIndex = self.tooltipSourceIndex + 1;
		end
		self.tooltipContentFrame:RefreshAppearanceTooltip();
	elseif key == WARDROBE_PREV_VISUAL_KEY or key == WARDROBE_NEXT_VISUAL_KEY or key == WARDROBE_UP_VISUAL_KEY or key == WARDROBE_DOWN_VISUAL_KEY then
		if self.activeFrame:CanHandleKey(key) then
			self:SetPropagateKeyboardInput(false);
			self.activeFrame:HandleKey(key);
		else
			self:SetPropagateKeyboardInput(true);
		end
	else
		self:SetPropagateKeyboardInput(true);
	end ]]
end


function CA_WardrobeCollectionFrameMixin:UpdateProgressBar(value, max)
	self.progressBar:SetMinMaxValues(0, max);
	self.progressBar:SetValue(value);
	self.progressBar.text:SetFormattedText(HEIRLOOMS_PROGRESS_FORMAT, value, max);
end



CA_ItemsCollectionMixin = { }


function CA_ItemsCollectionMixin:OnLoad()
	self:CreateSlotButtons(self);
	self.BGCornerTopLeft:Hide();
	self.BGCornerTopRight:Hide();

	self.NUM_ROWS = 3;
	self.NUM_COLS = 6;
	self.PAGE_SIZE = self.NUM_ROWS * self.NUM_COLS;

	-- UIDropDownMenu_Initialize(self.RightClickDropDown, nil, "MENU");
	-- self.RightClickDropDown.initialize = WardrobeCollectionFrameRightClickDropDown_Init;
	self.defaultCategory = "HEADSLOT"
end


local spacingNoSmallButton = 2;
local spacingWithSmallButton = 12;
local defaultSectionSpacing = 24;
local shorterSectionSpacing = 19;

function CA_ItemsCollectionMixin:CreateSlotButtons()
	local slots = { "head", "shoulder", "back", "chest", "shirt", "tabard", "wrist", defaultSectionSpacing, "hands", "waist", "legs", "feet", defaultSectionSpacing, "mainhand", spacingWithSmallButton, "secondaryhand" };
	--local slot_ids = { 1, 2, 3, 4, 5, 6, 7, nil, 8, 9, 10, 11, nil, 12, nil, 13 }
	local parentFrame = self.SlotsFrame;
	local lastButton;
	local xOffset = spacingNoSmallButton;
	for i = 1, #slots do
		local value = tonumber(slots[i]);
		if ( value ) then
			-- this is a spacer
			xOffset = value;
		else
			local slotString = slots[i];
			local button = CreateFrame("BUTTON", nil, parentFrame, "WardrobeSlotButtonTemplate");
			button.NormalTexture:SetAtlas("transmog-nav-slot-"..slotString, true);
			if ( lastButton ) then
				button:SetPoint("LEFT", lastButton, "RIGHT", xOffset, 0);
			else
				button:SetPoint("TOPLEFT");
			end
			button.slot = string.upper(slotString).."SLOT";
			--button.slot_id = slot_ids[i]

			xOffset = spacingNoSmallButton;
			lastButton = button;
			-- small buttons
			--[[ if ( slotString == "mainhand" or slotString == "secondaryhand" or slotString == "shoulder" ) then
				local smallButton = CreateFrame("BUTTON", nil, parentFrame, "WardrobeSmallSlotButtonTemplate");
				smallButton:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 16, -15);
				smallButton.slot = button.slot;
				if ( slotString == "shoulder" ) then
					smallButton.transmogLocation = TransmogUtil.GetTransmogLocation(smallButton.slot, Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary);

					smallButton.NormalTexture:SetAtlas("transmog-nav-slot-shoulder", false);
					smallButton:Hide();
				else
					smallButton.transmogLocation = TransmogUtil.GetTransmogLocation(smallButton.slot, Enum.TransmogType.Illusion, Enum.TransmogModification.Main);
				end
			end ]]
		end
	end
end

function CA_ItemsCollectionMixin:OnShow()
	self:SetActiveCategory(self.defaultCategory)
end

function CA_ItemsCollectionMixin:SetActiveCategory(category)
	local previousCategory = self.activeCategory;
	if self.activeCategory ~= category then
		self.activeCategory = category
		self:RefreshVisualsList();
		for i=1, #self.Models do
			local model = self.Models[i]
			model:Reload(category)
		end
		-- Not needed. Items get updated when resetting page which happens when user switches category
		--[[ self:UpdateItems(); ]]
	end

	local slotButtons = self.SlotsFrame.Buttons;
	for i = 1, #slotButtons do
		local button = slotButtons[i];
		button.SelectedTexture:SetShown(button.slot == self.activeCategory);
	end

	local resetPage = false;
	if previousCategory ~= category then
		resetPage = true;
	end
	if resetPage then
		self:ResetPage();
	end
end

function CA_ItemsCollectionMixin:ResetPage()
	local page = 1;
	self.PagingFrame:SetCurrentPage(page);
	self:UpdateItems();
end

function CA_ItemsCollectionMixin:RefreshVisualsList()
	self.visuals_list = app.GetVisualsList()
	--self:FilterVisuals();
	--self:SortVisuals();
	self.PagingFrame:SetMaxPages(ceil(#self.visuals_list / self.PAGE_SIZE));
end

function CA_ItemsCollectionMixin:UpdateProgressBar()
	local collected, total;
	collected = app.GetCategoryCollectedCount(self.activeCategory);
	total = app.GetCategoryTotal(self.activeCategory);
	self:GetParent():UpdateProgressBar(collected, total);
end

function CA_ItemsCollectionMixin:UpdateItems()
	local isArmor;
	local cameraID;

	local _, is_weapon = app.GetCategoryInfo(self.activeCategory);
	isArmor = not is_weapon;

	local indexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE;
	for i = 1, self.PAGE_SIZE do
		local model = self.Models[i];
		local index = i + indexOffset;
		local appearance_id = self.visuals_list[index];
		if ( appearance_id ) then
			model:Show();
			-- model:Reload(self.activeCategory)
			-- camera
			cameraID = app.GetAppearanceCameraID(appearance_id, self.activeCategory);
			--[[ if ( self.transmogLocation:IsAppearance() ) then
				cameraID = CA_GetAppearanceCameraID(visualInfo.visualID);
			end ]]
			if ( model.cameraID ~= cameraID ) then
				--print("DEBUG UpdateItems ["..i.."] - new cameraID:", model.cameraID, ">>>", cameraID)
				app.Model_ApplyUICamera(model, cameraID);
				model.cameraID = cameraID;
			end

 			--print("DEBUG UpdateItems ["..i.."] - appearance>", model.appearance_id, ">>>", appearance_id)
			if ( appearance_id ~= model.appearance_id) then
				if ( isArmor ) then
					--TEMP
					--[[ local sourceID = self:GetAnAppearanceSourceFromVisual(visualInfo.visualID, nil); ]]
					sourceID = "item:"..tostring(app.GetItemForModel(appearance_id))
					model:TryOn(sourceID);
				else
					model:SetItemAppearance(appearance_id);
				end
			end
			model.appearance_id = appearance_id;

			-- border
			--[[ if ( not visualInfo.isCollected ) then
				model.Border:SetAtlas("transmog-wardrobe-border-uncollected");
			elseif ( not visualInfo.isUsable ) then
				model.Border:SetAtlas("transmog-wardrobe-border-unusable");
			else
				model.Border:SetAtlas("transmog-wardrobe-border-collected");
			end ]]

			if ( GameTooltip:GetOwner() == model ) then
				model:OnEnter();
			end
		else
			model:Hide();
			model.visualInfo = nil;
		end
	end

	-- progress bar
	self:UpdateProgressBar();
end

function CA_ItemsCollectionMixin:GetActiveSlot()
	return self.activeCategory
	--[[ return self.transmogLocation and self.transmogLocation:GetSlotName(); ]]
end

function CA_ItemsCollectionMixin:OnHide()
	--[[ for i = 1, #self.Models do
		self.Models[i]:SetKeepModelOnHide(false);
	end ]]

	--[[ self.visuals_list = nil;
	self.activeCategory = nil; ]]
end

function CA_ItemsCollectionMixin:OnPageChanged(userAction)
	PlaySound(SOUNDKIT.UI_TRANSMOG_PAGE_TURN);
	CloseDropDownMenus();
	if ( userAction ) then
		self:UpdateItems();
	end
end

function CA_ItemsCollectionMixin:OnMouseWheel(delta)
	self.PagingFrame:OnMouseWheel(delta);
end






CA_ItemsModelMixin = { };

function CA_ItemsModelMixin:OnLoad()
	self:SetAutoDress(false)

	local lightValues = { omnidirectional = false, point = CreateVector3D(-1, 1, -1), ambientIntensity = 1.05, ambientColor = CreateColor(1, 1, 1), diffuseIntensity = 0, diffuseColor = CreateColor(1, 1, 1) }
	local enabled = true
	self:SetLight(enabled, lightValues)
	self.desaturated = false
end

function CA_ItemsModelMixin:OnModelLoaded()
	if ( self.cameraID ) then
		app.Model_ApplyUICamera(self, self.cameraID);
	end
	self.desaturated = false;
end

function CA_ItemsModelMixin:Reload(category)
	local _, is_weapon = app.GetCategoryInfo(category);
	if not is_weapon then
		self:SetUnit("player", false);
		self:Undress()
	end
	self:SetDoBlend(false);
	self:SetKeepModelOnHide(true);
	if ( self.cameraID ) then
		app.Model_ApplyUICamera(self, self.cameraID);
	end
	--app.Model_ApplyUICamera(self, 0) -- Reset camera (DEBUG MODE)
	self.cameraID = nil;
	self.needs_reload = nil;
end

function CA_ItemsModelMixin:OnShow()
	if ( self.needs_reload ) then
		self:Reload(self:GetParent():GetActiveSlot());
	end
end


local NON_EXISTING_ITEMS_CACHE = {}
local function is_checked_before(id)
    for key, _ in pairs(NON_EXISTING_ITEMS_CACHE) do
        if key == id then
            return true
        end
    end
	NON_EXISTING_ITEMS_CACHE[id] = true
    return false
end
function CA_ItemsModelMixin:OnEnter()
	if ( not self.appearance_id ) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:AddLine("Appearance ID: "..tostring(self.appearance_id))

	local not_existing_item_ids = {}
	local item_ids = app.GetAllItemIDsForModel(self)
	for i=1, #item_ids do
		local item_id = item_ids[i]
		local expansion = app.GetItemExpansionAndAppearanceID(item_id)
		local expansion_text = WrapTextInColorCode("<"..expansion..">", BATTLENET_FONT_COLOR:GenerateHexColor())
		local _, link = GetItemInfo(item_id)
		if link then
			GameTooltip:AddDoubleLine(link, expansion_text.." (ID: "..item_id..")")
			self.item_link = link
		else
			if is_checked_before(item_id) then
				local left_text = WrapTextInColorCode("<Not in the game yet>", LIGHTGRAY_FONT_COLOR:GenerateHexColor())
				local right_text = expansion_text.." (ID: "..item_id..")"
				GameTooltip:AddDoubleLine(left_text, right_text)
			else
				not_existing_item_ids[item_id] = i
				GameTooltip:AddDoubleLine("<item_link>", expansion_text.." (ID: "..item_id..")")
			end
		end
	end
	local non_existing_items_count = 0
	for _, _ in pairs(not_existing_item_ids) do
		non_existing_items_count = non_existing_items_count + 1
	end
	if non_existing_items_count ~= 0 then
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
		self:SetScript("OnEvent", function(...)
			local _, _, item_id_received, success = ...
			local line_number = not_existing_item_ids[item_id_received]
			if line_number then
				local tooltip_line_left = _G["GameTooltipTextLeft"..(line_number + 1)]
				local tooltip_line_right = _G["GameTooltipTextRight"..(line_number + 1)]
				local text
				if not success then
					text = "<Not in the game yet>"
					tooltip_line_left:SetTextColor(LIGHTGRAY_FONT_COLOR:GetRGBA())
					--tooltip_line_right:SetTextColor(LIGHTGRAY_FONT_COLOR:GetRGBA())
				else
					local _, link = GetItemInfo(item_id_received)
					text = link
					self.item_link = link
				end
				tooltip_line_left:SetText(text)
				GameTooltip:Show()
			end
		end)
	end

	GameTooltip:Show()
end

function CA_ItemsModelMixin:OnLeave()
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	GameTooltip:Hide()
end

function CA_ItemsModelMixin:OnMouseDown(button)
	if IsShiftKeyDown() then
		local INDENTATION = "   "
		local THIS_MARK = WrapTextInColorCode("<<<", GREEN_FONT_COLOR:GenerateHexColor())

		local item_ids = app.GetAllItemIDsForModel(self)
		if item_ids then
			print(WrapTextInColorCode("Shared appearances:", NORMAL_FONT_COLOR:GenerateHexColor()))
			for i=1, #item_ids do
				local item_id = item_ids[i]
				local id_text = WrapTextInColorCode("(ID: "..item_id..")", NORMAL_FONT_COLOR:GenerateHexColor())
				local expansion = app.GetItemExpansionAndAppearanceID(item_id)
				local expansion_text = WrapTextInColorCode("<"..expansion..">", BATTLENET_FONT_COLOR:GenerateHexColor())
				local _, link = GetItemInfo(item_id)
				if link then
					local text_line = INDENTATION..link.." "..expansion_text.." "..id_text
					print(text_line)
				else
					if is_checked_before(item_id) then
						local text_line = WrapTextInColorCode("<Not in the game yet>", LIGHTGRAY_FONT_COLOR:GenerateHexColor())
						print(INDENTATION..text_line.." "..expansion_text.." "..id_text)
					else
						print("DEBUG ItemButton OnMouseDown Unexpected behaviour")
					end
				end
			end
		end
	elseif IsControlKeyDown() and self.item_link then
		DressUpItemLink(self.item_link)
	end
end



CA_SlotButtonMixin = { }

function CA_SlotButtonMixin:OnClick()
	PlaySound(SOUNDKIT.UI_TRANSMOG_GEAR_SLOT_CLICK);
	self:GetParent():GetParent():SetActiveCategory(self.slot)
end

function CA_SlotButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local slotName = _G[self.slot];
	GameTooltip:SetText(slotName);
end







-- OLD
function CA_ItemsCollectionMixin:SetActiveCategory_OLD(category)
	local previousCategory = self.activeCategory;
	self.activeCategory = category;

	if previousCategory ~= category then
		self:RefreshVisualsList();
	else
		self:RefreshVisualsList();
		self:UpdateItems();
	end

	local slotButtons = self.SlotsFrame.Buttons;
	for i = 1, #slotButtons do
		local button = slotButtons[i];
		button.SelectedTexture:SetShown(button.slot == self.activeCategory);
	end

	local resetPage = false;
	if previousCategory ~= category then
		resetPage = true;
	end
	if resetPage then
		self:ResetPage();
	end
end
-- OLD
function CA_ItemsCollectionMixin:UpdateItems_OLD()
	print("DEBUG UpdateItems")

	local is_armor;
	local _, is_weapon = app.GetCategoryInfo(self.activeCategory);
	is_armor = not is_weapon;

	local indexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE;
	for i = 1, self.PAGE_SIZE do
		local model = self.Models[i];
		local index = i + indexOffset;
		local appearance_id = self.visuals_list[index];
		local cameraID;

		model:Reload2(self.activeCategory)

		if ( appearance_id ) then
			model:Show();
			-- camera
			cameraID = app.GetAppearanceCameraID(appearance_id);
			--[[ if ( self.transmogLocation:IsAppearance() ) then
				cameraID = CA_GetAppearanceCameraID(visualInfo.visualID);
			end ]]
			if ( model.cameraID ~= cameraID ) then
				print("DEBUG UpdateItems ["..i.."] - new cameraID:", model.cameraID, ">>>", cameraID)
				app.Model_ApplyUICamera(model, cameraID);
				model.cameraID = cameraID;
			end

 			print("DEBUG UpdateItems ["..i.."] - appearance>", model.appearance_id, ">>>", appearance_id)
			if ( appearance_id ~= model.appearance_id) then
				if ( is_armor ) then
					--TEMP
					--[[ local sourceID = self:GetAnAppearanceSourceFromVisual(visualInfo.visualID, nil); ]]
					sourceID = "item:51158"
					model:TryOn(sourceID);
				else
					model:SetItemAppearance(appearance_id);
				end
			end
			model.appearance_id = appearance_id;

			-- border
			--[[ if ( not visualInfo.isCollected ) then
				model.Border:SetAtlas("transmog-wardrobe-border-uncollected");
			elseif ( not visualInfo.isUsable ) then
				model.Border:SetAtlas("transmog-wardrobe-border-unusable");
			else
				model.Border:SetAtlas("transmog-wardrobe-border-collected");
			end ]]

			if ( GameTooltip:GetOwner() == model ) then
				model:OnEnter();
			end
		else
			model:Hide();
			model.visualInfo = nil;
		end
	end

	-- progress bar
	--[[ self:UpdateProgressBar(); ]]
end

-- OLD
function CA_ItemsModelMixin:Reload_OLD(reloadSlot)
	print("DEBUG reload")
	if ( self:IsShown() ) then
		if ( WARDROBE_MODEL_SETUP[reloadSlot] ) then
			--[[ local useTransmogSkin = GetUseTransmogSkin(reloadSlot);
			self:SetUseTransmogSkin(useTransmogSkin);
			self:SetUseTransmogChoices(WARDROBE_MODEL_SETUP[reloadSlot].useTransmogChoices);
			self:SetObeyHideInTransmogFlag(WARDROBE_MODEL_SETUP[reloadSlot].obeyHideInTransmogFlag); ]]
			self:SetUnit("player", false);
			self:SetDoBlend(false);
			for slot, equip in pairs(WARDROBE_MODEL_SETUP[reloadSlot].slots) do
				if ( equip ) then
					self:TryOn(WARDROBE_MODEL_SETUP_GEAR[slot]);
				end
			end
		end
		self:SetKeepModelOnHide(true);
		self.cameraID = nil;
		self.needsReload = nil;
	else
		self.needsReload = true;
	end
end