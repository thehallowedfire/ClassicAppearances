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
	print("CA_WardrobeCollectionFrameMixin:OnKeyDown", key)
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

	--UIDropDownMenu_Initialize(self.RightClickDropDown, nil, "MENU");
	--self.RightClickDropDown.initialize = WardrobeCollectionFrameRightClickDropDown_Init;
	self.default_category = "HEADSLOT"
	local possible_mainhand_categories, possible_secondaryhand_categories = app.GetPossibleWeaponCategories()
	self.last_mainhand_category_id = possible_mainhand_categories[1]
	self.last_secondaryhand_category_id = possible_secondaryhand_categories[1]
end


local spacingNoSmallButton = 2;
local spacingWithSmallButton = 12;
local defaultSectionSpacing = 24;
local shorterSectionSpacing = 19;

function CA_ItemsCollectionMixin:CreateSlotButtons()
	local slots = { "head", "shoulder", "back", "chest", "shirt", "tabard", "wrist", defaultSectionSpacing, "hands", "waist", "legs", "feet", defaultSectionSpacing, "mainhand", spacingWithSmallButton, "secondaryhand" };
	--local slot_ids = { 1, 2, 3, 4, 6, 7, 8, nil, 9, 10, 11, 12, nil, 13, nil, 29 }
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
	--self:UpdateWeaponDropDown();
	app.ScanItems()
	self:RefreshVisualsList(app.GetCategoryID(self.default_category));
	self:SetActiveSlot(self.default_category)
end

function CA_ItemsCollectionMixin:UpdateWeaponDropDown()
	local dropdown = self.WeaponDropDown;
	local name, isWeapon = app.GetCategoryInfo(self.active_category_id);
	if ( not isWeapon ) then
		dropdown:Show();
		UIDropDownMenu_DisableDropDown(dropdown);
		UIDropDownMenu_SetText(dropdown, "");
	else
		dropdown:Show();
		UIDropDownMenu_SetSelectedValue(dropdown, self.active_category_id);
		UIDropDownMenu_SetText(dropdown, name);
		local validCategories = CA_WardrobeCollectionFrameWeaponDropDown_Init(dropdown);
		if ( validCategories > 1 ) then
			UIDropDownMenu_EnableDropDown(dropdown);
		else
			UIDropDownMenu_DisableDropDown(dropdown);
		end
	end
end

function CA_ItemsCollectionMixin:SetActiveSlot(category)
	local category_id = app.GetCategoryID(category)
	if category_id ~= self.active_category_id or self.needs_reload then
		self.active_slot = category

		if self.needs_reload then
			local possible_mainhand_categories, possible_secondaryhand_categories = app.GetPossibleWeaponCategories()
			self.last_mainhand_category_id = possible_mainhand_categories[1]
			self.last_secondaryhand_category_id = possible_secondaryhand_categories[1]
		end

		if category == "MAINHANDSLOT" then
			category_id = self.last_mainhand_category_id
		elseif category == "SECONDARYHANDSLOT" then
			category_id = self.last_secondaryhand_category_id
		end

		self:SetActiveCategory(category_id)

		local slotButtons = self.SlotsFrame.Buttons;
		for i = 1, #slotButtons do
			local button = slotButtons[i];
			button.SelectedTexture:SetShown(button.slot == category);
		end
	end
	CloseDropDownMenus();
end

function CA_ItemsCollectionMixin:SetActiveCategory(category_id)
	local previousCategory = self.active_category_id;
	if self.active_category_id ~= category_id or self.needs_reload then
		if self.active_slot == "MAINHANDSLOT" then
			self.last_mainhand_category_id = category_id
		elseif self.active_slot == "SECONDARYHANDSLOT" then
			self.last_secondaryhand_category_id = category_id
		end

		self.active_category_id = category_id
		self:RefreshVisualsList(category_id);

		for i=1, #self.Models do
			local model = self.Models[i]
			model:Reload(category_id)
		end

		-- progress bar
		self:UpdateProgressBar();

		-- Not needed. Items get updated when resetting page which happens when user switches category
		--[[ self:UpdateItems(); ]]
	end
	self:UpdateWeaponDropDown();

	local resetPage = false;
	if previousCategory ~= category_id or self.needs_reload then
		resetPage = true;
	end
	if resetPage then
		self:ResetPage();
		self.needs_reload = nil
	end
end

function CA_ItemsCollectionMixin:ResetPage()
	local page = 1;
	self.PagingFrame:SetCurrentPage(page);
	self:UpdateItems();
end

function CA_ItemsCollectionMixin:RefreshVisualsList(category_id)
	self.visuals_list, self.collected_count, self.collected_visuals_table = app.GetVisualsList(category_id)
	--self:FilterVisuals();
	--self:SortVisuals();
	self.PagingFrame:SetMaxPages(ceil(#self.visuals_list / self.PAGE_SIZE));
end

function CA_ItemsCollectionMixin:UpdateProgressBar()
	local collected, total
	collected = self.collected_count
	total = #self.visuals_list
	self:GetParent():UpdateProgressBar(collected, total)
end

function CA_ItemsCollectionMixin:UpdateItems()
	local isArmor;
	local cameraID;

	local _, is_weapon = app.GetCategoryInfo(self.active_category_id);
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
			cameraID = app.GetAppearanceCameraID(appearance_id, self.active_category_id);
			--[[ if ( self.transmogLocation:IsAppearance() ) then
				cameraID = CA_GetAppearanceCameraID(visualInfo.visualID);
			end ]]
			if ( model.cameraID ~= cameraID ) then
				--print("DEBUG UpdateItems ["..i.."] - new cameraID:", model.cameraID, ">>>", cameraID)
				app.Model_ApplyUICamera(model, cameraID);
				model.cameraID = cameraID;
			end

 			--print("DEBUG UpdateItems ["..i.."] - appearance>", model.appearance_id, ">>>", appearance_id)
			if ( appearance_id ~= model.appearance_id or self.needs_reload) then
				local item_id = app.GetItemForModel(appearance_id)
				if ( isArmor ) then
					sourceID = "item:"..tostring(item_id)
					model:TryOn(sourceID);
				else
					--model:SetItemAppearance(appearance_id);
					model:SetItem(item_id)
				end
			end
			model.appearance_id = appearance_id;

			-- border
			if ( not self.collected_visuals_table[appearance_id] ) then
				model.Border:SetAtlas("transmog-wardrobe-border-uncollected");
				model.is_collected = nil
			--[[ elseif ( not visualInfo.isUsable ) then
				model.Border:SetAtlas("transmog-wardrobe-border-unusable"); ]]
			else
				model.Border:SetAtlas("transmog-wardrobe-border-collected");
				model.is_collected = true
			end

			if ( GameTooltip:GetOwner() == model ) then
				model:OnEnter();
			end
		else
			model:Hide();
			model.visualInfo = nil;
		end
	end
end

function CA_ItemsCollectionMixin:GetActiveSlot()
	return self.active_category_id
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
	PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
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

function CA_ItemsModelMixin:Reload(category_id)
	local _, is_weapon = app.GetCategoryInfo(category_id);
	if not is_weapon then
		self:SetUnit("player", false);
	end
	self:Undress()
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



local KNOWN_SYMBOL = "\124T".."Interface\\AddOns\\ClassicAppearances\\Assets\\known"..":0\124t"
local KNOWN_CIRCLE_SYMBOL = "\124T".."Interface\\AddOns\\ClassicAppearances\\Assets\\known_circle"..":0\124t"
local UNKNOWN_SYMBOL = "\124T".."Interface\\AddOns\\ClassicAppearances\\Assets\\unknown"..":0\124t"
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
local function get_full_name(full_name)
	local name, server = string.match(full_name, "(.-)%-(.*)")
	local player_name, player_server = string.match(app.player_full_name, "(.-)%-(.*)")
	if player_server == server then
		full_name = name
	end
	return full_name
end
function CA_ItemsModelMixin:OnEnter()
	if ( not self.appearance_id ) then
		return;
	end

	local right_title = UNKNOWN_SYMBOL.." Not Collected"
	local color = "ffff9333"
	if self.is_collected then
		right_title = KNOWN_CIRCLE_SYMBOL.." Collected"
		color = "ff15abff"
	end
	right_title = WrapTextInColorCode(right_title, color)

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:AddDoubleLine("Appearance ID: "..tostring(self.appearance_id), right_title)

	local not_existing_item_ids = {}
	local item_info_cache = {}
	local item_ids = app.GetAllItemIDsForAppearance(self.appearance_id)
	for i=1, #item_ids do
		local item_id = item_ids[i]
		local _, expansion = app.GetItemAppearanceIDAndExpansion(item_id)
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

		if self.is_collected then
			local owner = app.GetItemOwner(item_id)
			if owner == app.player_full_name then
				local text = WrapTextInColorCode(KNOWN_SYMBOL.." Collected", "ff15abff")
				GameTooltipTextRight1:SetText(text)
			end
			local text_line = _G["GameTooltipTextRight"..(i + 1)]
			item_info_cache[i] = {text_line:GetText(), owner}
		else
			item_info_cache = {}
		end
	end

	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	self:HookScript("OnEvent", function(self, event, key, down)
		if self.is_collected and event == "MODIFIER_STATE_CHANGED" and key == "LALT" then
			if down == 1 then
				for i=1, #item_info_cache do
					local owner = item_info_cache[i][2]
					local text_line = _G["GameTooltipTextRight"..(i + 1)]
					if owner then
						if owner == app.player_full_name then
							text_line:SetText(WrapTextInColorCode(get_full_name(owner).." "..KNOWN_SYMBOL, "ff15abff"))
						else
							text_line:SetText(WrapTextInColorCode(get_full_name(owner).." "..KNOWN_CIRCLE_SYMBOL, "ff15abff"))
						end
					else
						text_line:SetText(UNKNOWN_SYMBOL)
					end
				end
			elseif down == 0 then
				for i=1, #item_info_cache do
					local text_line = _G["GameTooltipTextRight"..(i + 1)]
					text_line:SetText(item_info_cache[i][1])
				end
				GameTooltip:Show()
			end
		end
	end)

	local non_existing_items_count = 0
	for _, _ in pairs(not_existing_item_ids) do
		non_existing_items_count = non_existing_items_count + 1
	end
	if non_existing_items_count ~= 0 then
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
		self:HookScript("OnEvent", function(...)
			local _, event, item_id_received, success = ...
			if event == "GET_ITEM_INFO_RECEIVED" then
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
						NON_EXISTING_ITEMS_CACHE[item_id_received] = nil
					end
					tooltip_line_left:SetText(text)
					GameTooltip:Show()
				end
			end
		end)
	end

	GameTooltip:Show()
end

function CA_ItemsModelMixin:OnLeave()
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:Hide()
end

function CA_ItemsModelMixin:OnMouseDown(button)
	if IsShiftKeyDown() then
		local INDENTATION = "   "
		local THIS_MARK = WrapTextInColorCode("<<<", GREEN_FONT_COLOR:GenerateHexColor())

		local item_ids = app.GetAllItemIDsForAppearance(self.appearance_id)
		if item_ids then
			print(WrapTextInColorCode("Shared appearances:", NORMAL_FONT_COLOR:GenerateHexColor()))
			for i=1, #item_ids do
				local item_id = item_ids[i]
				local id_text = WrapTextInColorCode("(ID: "..item_id..")", NORMAL_FONT_COLOR:GenerateHexColor())
				local _, expansion = app.GetItemAppearanceIDAndExpansion(item_id)
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
	PlaySound(902);
	if self.slot ~= self:GetParent():GetParent().active_slot then
		self:GetParent():GetParent():SetActiveSlot(self.slot)
	end
end

function CA_SlotButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local slotName = _G[self.slot];
	GameTooltip:SetText(slotName);
end



-- ***** WEAPON DROPDOWN
function CA_WardrobeCollectionFrameWeaponDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, CA_WardrobeCollectionFrameWeaponDropDown_Init);
	UIDropDownMenu_SetWidth(self, 140);
end

function CA_WardrobeCollectionFrameWeaponDropDown_Init(self)
	--[[ local transmogLocation = WardrobeCollectionFrame.ItemsCollectionFrame.transmogLocation;
	if ( not transmogLocation ) then
		return;
	end ]]

	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();
	info.func = CA_WardrobeCollectionFrameWeaponDropDown_OnClick;

	--[[ local equippedItemID = GetInventoryItemID("player", transmogLocation:GetSlotID());
	local checkCategory = equippedItemID and C_Transmog.IsAtTransmogNPC();
	if ( checkCategory ) then
		-- if the equipped item cannot be transmogrified, relax restrictions
		local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo = C_Transmog.GetSlotInfo(transmogLocation);
		if ( not canTransmogrify and not hasUndo ) then
			checkCategory = false;
		end
	end ]]
	local buttonsAdded = 0;

	--local isForMainHand = transmogLocation:IsMainHand();
	--local isForOffHand = transmogLocation:IsOffHand();
	local possible_mainhand_categories, possible_secondaryhand_categories = app.GetPossibleWeaponCategories()
	local weapon_categories
	local active_slot = WardrobeCollectionFrame.ItemsCollectionFrame.active_slot
	if active_slot == "MAINHANDSLOT" then
		weapon_categories = possible_mainhand_categories
	elseif active_slot == "SECONDARYHANDSLOT" then
		weapon_categories = possible_secondaryhand_categories
	end

	if weapon_categories then
		for i=1, #weapon_categories do
			local category_id = weapon_categories[i]
			local name = app.GetCategoryInfo(category_id);

			info.text = name;
			info.arg1 = category_id;
			info.value = category_id;
			if ( info.value == selectedValue ) then
				info.checked = 1;
			else
				info.checked = nil;
			end
			UIDropDownMenu_AddButton(info);
			buttonsAdded = buttonsAdded + 1;
		end
	end
	return buttonsAdded;
end

function CA_WardrobeCollectionFrameWeaponDropDown_OnClick(self, category)
	if ( category and WardrobeCollectionFrame.ItemsCollectionFrame.active_category_id ~= category ) then
		CloseDropDownMenus();
		WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveCategory(category);
	end
end


-- ***** FILTER DROPDOWN
function CA_ItemFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, CA_ItemFilterDropDown_Init);
	UIDropDownMenu_SetWidth(self, 74);
end

function CA_ItemFilterDropDown_Init(self)
	local _, class, class_id = UnitClass("player")
	local _, _, _, class_color = GetClassColor(class)
	local class_name = WrapTextInColorCode(GetClassInfo(class_id), class_color)

	local dropdown = WardrobeCollectionFrameClassDropDown
	if not app.GetSettings('class_filter_enabled') then
		UIDropDownMenu_SetText(dropdown, ALL_CLASSES);
	else
		UIDropDownMenu_SetText(dropdown, class_name);
	end


	local info = UIDropDownMenu_CreateInfo();
	info.func = CA_ItemFilterDropDown_OnClick;

	info.text = ALL_CLASSES
	info.checked = not app.GetSettings('class_filter_enabled')
	info.arg1 = 1
	UIDropDownMenu_AddButton(info);

	info.text = class_name
	info.checked = app.GetSettings('class_filter_enabled')
	info.arg1 = 2
	UIDropDownMenu_AddButton(info);

	return 2;
end

function CA_ItemFilterDropDown_OnClick(self, arg1, arg2, checked)
	if not checked then
		if arg1 == 1 then
			app.SetSettings('class_filter_enabled', false)
		elseif arg1 == 2 then
			app.SetSettings('class_filter_enabled', true)
		end
		local dropdown = WardrobeCollectionFrameClassDropDown
		UIDropDownMenu_SetText(dropdown, self.value)

		local frame = WardrobeCollectionFrame.ItemsCollectionFrame
		frame.needs_reload = true
		frame:SetActiveSlot(frame.active_slot)
	end
end

